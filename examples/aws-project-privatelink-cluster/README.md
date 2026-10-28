# Walkthrough: project, AWS PrivateLink, and a sharded cluster

This walkthrough deploys the three most common modules together and shows what a healthy `terraform plan` looks like at each step:

- [project](https://registry.terraform.io/modules/terraform-mongodbatlas-modules/project/mongodbatlas/latest): The Atlas project.
- [atlas-aws](https://registry.terraform.io/modules/terraform-mongodbatlas-modules/atlas-aws/mongodbatlas/latest): AWS PrivateLink into your VPC.
- [cluster](https://registry.terraform.io/modules/terraform-mongodbatlas-modules/cluster/mongodbatlas/latest): A sharded cluster with auto-scaling and backups.

Everything lives in one [main.tf](./main.tf). Every value is hard-coded except `tags`, which has a default, so you can compare your own configuration and plan with this one line by line.

- **Step 1:** One region (us-east-1). Apply `main.tf` as is.
- **Step 2:** Add a second region (us-west-2). Uncomment every block marked `STEP 2`. You can start here: uncomment the blocks first, and this becomes a two-region deployment from a single apply. This walkthrough runs it after step 1 to show the incremental change and the plan it produces.
- **Step 3 (talkthrough only):** Insert a third region in the middle of the `regions` list. Not part of `main.tf`; shows a plan that needs extra attention.

Verified with project 1.0.0, atlas-aws 1.0.0, cluster 1.0.0, [terraform-aws-modules/vpc](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) 6.7.3, `mongodb/mongodbatlas` 2.20.1, `hashicorp/aws` 6.70.0, and Terraform 1.15.9 on 2026-10-28. No `.terraform.lock.hcl` is committed: a fresh `terraform init` resolves the latest module and provider versions within the `~>` constraints, so what you get can be newer than the verified run. Captured output is in [outputs/](./outputs) with IDs and hostnames redacted.

## Prerequisites

- Atlas credentials exported as environment variables. See [Getting started](../../docs/getting-started.md#credentials). The org ID comes from the credentials through the `mongodbatlas_roles_org_id` data source.
- AWS credentials for an account where you can create VPCs and VPC endpoints in us-east-1 and us-west-2.
- [Terraform](https://developer.hashicorp.com/terraform/install) 1.10 or newer.

-> IMPORTANT NOTE: This walkthrough creates dedicated Atlas clusters and AWS VPC endpoints that are billed while they run. Run `terraform destroy` when you are done.

## Step 1: Deploy one region

```sh
terraform init
terraform plan -out=step1.tfplan
terraform apply step1.tfplan
```

### What gets created

The plan shows `Plan: 21 to add, 0 to change, 0 to destroy.` Atlas output with the vpc module resources omitted: [outputs/step1-plan.txt](./outputs/step1-plan.txt).

- **`module.vpc_region1` (13 resources):** The network PrivateLink attaches to.
  - `aws_vpc.this[0]`: The VPC (`10.10.0.0/16`).
  - `aws_subnet.private[0..2]`: One private subnet per availability zone.
  - `aws_route_table.private[0..2]` and `aws_route_table_association.private[0..2]`: One route table per private subnet.
  - `aws_default_network_acl.this[0]`, `aws_default_route_table.default[0]`, `aws_default_security_group.this[0]`: The vpc module brings the VPC's default network ACL, route table, and security group under Terraform management.
- **`module.atlas_project` (1 resource):** `mongodbatlas_project.this[0]` with the `tags` from `var.tags`.
- **`module.atlas_aws` (5 resources):** One PrivateLink connection, keyed by region (`["us-east-1"]`).
  - `mongodbatlas_privatelink_endpoint.this["us-east-1"]`: The Atlas side: an endpoint service in the Atlas project.
  - `module.privatelink["us-east-1"].aws_vpc_endpoint.this[0]`: The AWS side: an interface endpoint in your subnets.
  - `module.privatelink["us-east-1"].aws_security_group.this[0]` and `aws_security_group_rule.ingress_cidr[0]`: Allows inbound TCP ports 1024-65535 to the endpoint, from the VPC CIDR by default.
  - `module.privatelink["us-east-1"].mongodbatlas_privatelink_endpoint_service.this`: Registers the AWS endpoint with Atlas.
- **`module.atlas_cluster` (2 resources):**
  - `mongodbatlas_advanced_cluster.this`: `cluster_type = "SHARDED"`, one shard, 3 electable nodes in `US_EAST_1`, auto-scaling from M10 to M200.
  - `module.backup_schedule[0].mongodbatlas_cloud_backup_schedule.this`: The module's default backup schedule.

The plan also lists data sources marked `will be read during apply`. They depend on IDs that do not exist yet. That is expected.

### What good looks like

- `0 to change, 0 to destroy` on a first apply.
- The cluster and the PrivateLink endpoint service take the longest, and they run in parallel. In the verified run, the cluster took 20 minutes and the endpoint service 13 minutes. Apply summary: [outputs/step1-apply.txt](./outputs/step1-apply.txt).
- After apply, `terraform output privatelink` shows `status = "AVAILABLE"` for `us-east-1`, and `terraform output connection_strings` includes a `private_endpoint` entry with a `mongodb+srv://lz-walkthrough-pl-0-lb...` string. If the private entry is missing, the cluster finished before the endpoint service became available: wait for `status = "AVAILABLE"`, run `terraform apply -refresh-only`, then read the output again.
- Running `terraform plan` again shows `No changes. Your infrastructure matches the configuration.`

## Step 2: Add a second region

Uncomment the three blocks marked `STEP 2` in `main.tf`. Remove only the leading `# ` on each line, then run `terraform init` again: it installs the newly uncommented `module "vpc_region2"` block before the plan can run.

### Configuration change

```diff
+module "vpc_region2" {
+  source  = "terraform-aws-modules/vpc/aws"
+  version = "~> 6.7"
+
+  name            = "lz-walkthrough-region2"
+  region          = "us-west-2"
+  cidr            = "10.20.0.0/16"
+  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
+  private_subnets = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
+}
```

```diff
   privatelink_endpoints = [
     {
       region     = "us-east-1"
       subnet_ids = module.vpc_region1.private_subnets
     },
+    {
+      region     = "us-west-2"
+      subnet_ids = module.vpc_region2.private_subnets
+    },
   ]
```

```diff
   regions = [
     {
       name       = "US_EAST_1"
       node_count = 3
       shard_name = "s1"
     },
+    {
+      name       = "US_WEST_2"
+      node_count = 2
+      shard_name = "s1"
+    },
   ]
```

Then run:

```sh
terraform plan -out=step2.tfplan
terraform apply step2.tfplan
```

### Plan change

The plan shows `Plan: 18 to add, 1 to change, 0 to destroy.` Atlas output with the vpc module resources omitted: [outputs/step2-plan.txt](./outputs/step2-plan.txt).

- **`module "vpc_region2"` adds 13 resources:** The same set as `module.vpc_region1` in step 1, in us-west-2.
- **The `us-west-2` PrivateLink entry adds 5 resources:** All keyed `["us-west-2"]`. The existing `["us-east-1"]` resources do not appear in the plan, because atlas-aws keys endpoints by region, not by list position.
- **The `US_WEST_2` region updates the cluster in place:** `module.atlas_cluster.mongodbatlas_advanced_cluster.this will be updated in-place`. The relevant part:

```text
      ~ replication_specs                                      = [
          ~ {
              ~ region_configs = [
                  ~ {
                        # US_EAST_1: computed disk and analytics values only
                        # (5 unchanged attributes hidden)
                    },
                  + {
                      + electable_specs        = {
                          + instance_size   = "M10"
                          + node_count      = 2
                        }
                      + priority               = 6
                      + provider_name          = "AWS"
                      + region_name            = "US_WEST_2"
                    },
                ]
```

The module assigns `priority` by list order: the first region gets 7, the next 6, and so on. `US_EAST_1` keeps priority 7, so it stays the preferred region for the primary.

The plan also shows the existing `private_endpoint` connection string going to `null`. That is a computed value. Atlas recalculates it after the region is added; it does not mean PrivateLink is removed.

### What good looks like

- `0 to destroy`, and no `must be replaced` anywhere in the plan.
- No `-` lines inside `region_configs` for `US_EAST_1` other than `(known after apply)` on computed values such as `disk_iops`.
- The cluster update took 16 minutes in the verified run. The cluster stays available while Atlas adds the nodes. Apply summary: [outputs/step2-apply.txt](./outputs/step2-apply.txt).
- After apply, both PrivateLink entries show `status = "AVAILABLE"`, and `connection_strings.private_endpoint` lists endpoints in `US_EAST_1` and `US_WEST_2`.

-> IMPORTANT NOTE: The PrivateLink SRV hostname changed in the verified run, from `lz-walkthrough-pl-0-lb...` (one region) to `lz-walkthrough-pl-0...` (two regions). Read the new value from `terraform output connection_strings` and update any application that pins the old string.

## Step 3 (talkthrough): Insert a region in the middle

This step is not in `main.tf`. It shows what happens to the cluster when a region is added in the middle of `regions` instead of at the end. To try it, add a third VPC module (us-east-2, for example `10.30.0.0/16`) and a `us-east-2` PrivateLink entry the same way as in step 2, run `terraform init` to install the new module block, then insert the region:

```diff
   regions = [
     {
       name       = "US_EAST_1"
       node_count = 3
       shard_name = "s1"
     },
+    {
+      name       = "US_EAST_2"
+      node_count = 2
+      shard_name = "s1"
+    },
     {
       name       = "US_WEST_2"
       node_count = 2
       shard_name = "s1"
     },
   ]
```

The VPC and PrivateLink resources for us-east-2 are pure additions, as in step 2. The cluster part is the interesting one. Cluster-only excerpt: [outputs/step3-middle-region-cluster-plan.txt](./outputs/step3-middle-region-cluster-plan.txt).

```text
  # module.atlas_cluster.mongodbatlas_advanced_cluster.this will be updated in-place
              ~ region_configs = [
                  ~ {
                        # US_EAST_1, priority 7: computed disk and analytics values only
                        # (5 unchanged attributes hidden)
                    },
                  ~ {
                      ~ electable_specs        = {
                            # (2 unchanged attributes hidden)
                        }
                      ~ region_name            = "US_WEST_2" -> "US_EAST_2"
                        # (4 unchanged attributes hidden)
                    },
                  + {
                      + electable_specs        = {
                          + instance_size   = "M10"
                          + node_count      = 2
                        }
                      + priority               = 5
                      + provider_name          = "AWS"
                      + region_name            = "US_WEST_2"
                    },
                ]
```

Terraform compares `region_configs` by list position, so the plan reads like `US_WEST_2` is renamed to `US_EAST_2` and a new `US_WEST_2` is added. What actually changes in Atlas:

- `US_EAST_2` is added with priority 6.
- `US_WEST_2` moves from priority 6 to priority 5.
- `US_EAST_1` is unchanged.

The plan is still `0 to destroy`, but it needs extra attention:

- **Priority changes affect failover order.** If you care which secondary region takes over the primary, check the new order before applying.
- **Instance sizes follow the position, not the region name.** The entry at position 1 keeps its current electable instance size (hidden as unchanged), so `US_EAST_2` starts at the size `US_WEST_2` had. The re-added `US_WEST_2` at position 2 starts at `M10`. In the verified run both were `M10`; if auto-scaling has already scaled `US_WEST_2` up, check these values before applying.
- **Prefer appending.** Adding new regions at the end of `regions` (as in step 2) keeps every existing `region_configs` entry in place, and the plan shows only additions.

## Clean up

```sh
terraform destroy
```

If the destroy fails partway, run it again. The cluster module defaults to `retain_backups_enabled = true` (recommended for production), so `terraform destroy` retains the cluster's backup snapshots. For this disposable walkthrough, set `retain_backups_enabled = false` on `module.atlas_cluster` before destroying if you do not need the snapshots; otherwise delete the retained snapshots afterwards, as they can incur charges. If you removed resources from state or deleted them outside Terraform, see [Troubleshooting plan changes](../../docs/troubleshooting.md).

## Next steps

- [Troubleshooting plan changes](../../docs/troubleshooting.md): Safe vs risky changes, drift, and recovering from conflicts.
- [Debug guide](../../docs/debug.md): Logging and what to include in an issue or support case.
- [Cluster topology guide](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-cluster/blob/main/docs/cluster_topology.md): Every option for `regions`, shards, and zones.
- [atlas-aws README](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-atlas-aws): PrivateLink options such as bring-your-own endpoint and cross-region endpoints.
