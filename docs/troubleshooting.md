# Troubleshooting plan changes

Use this guide when `terraform plan` shows something you did not expect: a replacement, a change you did not make, or an error on apply. For logging and where to report issues, see the [Debug guide](./debug.md).

The examples come from the [project, PrivateLink, and cluster walkthrough](../examples/aws-project-privatelink-cluster/README.md). Compare your plan with the captured output there.

## Read the plan symbols

Each resource line in a plan starts with a symbol:

- **`+` create:** A new resource. Safe in most cases.
- **`~` update in-place:** Atlas or AWS changes the existing resource without deleting it. The impact depends on the change: adding a region can take 15 minutes or more, and some updates (pausing the cluster, for example) make it unavailable or trigger rolling restarts. Check the specific attribute before applying.
- **`-/+` destroy and then create (`must be replaced`):** Terraform deletes the resource and creates a new one. On a cluster, this deletes the cluster and its data. Stop and find the attribute marked `# forces replacement` before applying.
- **`-` destroy:** Terraform deletes the resource.
- **`<=` read:** A data source. `will be read during apply` is expected when it depends on a resource that does not exist yet or has pending changes. See [Replacements when nothing changed](#replacements-when-nothing-changed) for when a deferred read turns into a replacement.

Check the summary line first. For any change to an existing deployment, `0 to destroy` is the normal case:

```text
Plan: 18 to add, 1 to change, 0 to destroy.
```

## Changes that are usually safe

These produce only `+` or `~` lines on Atlas resources:

- **Adding a region at the end of `regions`:** An in-place cluster update. See [step 2 of the walkthrough](../examples/aws-project-privatelink-cluster/README.md#step-2-add-a-second-region).
- **Adding a PrivateLink entry to `privatelink_endpoints`:** atlas-aws keys endpoints by region, so existing endpoints are untouched no matter where you add the entry.
- **Changing `node_count` for an existing region:** An in-place update.
- **Changing `tags`:** An in-place update on the project, the cluster, and AWS resources.

## Changes that need extra attention

Plan these in a non-production workspace first and read every `~` line on the cluster:

- **Inserting, removing, or reordering entries in `regions`:** The cluster module assigns priorities by list order (7, 6, 5, ...), and Terraform compares `region_configs` by position. Inserting a region in the middle shows an existing region being renamed and re-added. See [step 3 of the walkthrough](../examples/aws-project-privatelink-cluster/README.md#step-3-talkthrough-insert-a-region-in-the-middle).
- **Clusters with more than one shard:** Adding, removing, or reordering shards can match settings to the wrong shard. See [Does the module have cluster topology change limitations?](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-cluster#does-the-module-have-cluster-topology-change-limitations).
- **Changing a region in `privatelink_endpoints`:** The region is the endpoint key, so the old endpoint is destroyed and a new one is created. Applications using the old PrivateLink connection string lose connectivity until they switch.
- **PrivateLink connection strings after adding a region:** The SRV hostname can change (for example from `...-pl-0-lb...` to `...-pl-0...`). Read the new value from the cluster module's `connection_strings` output after apply.
- **Enabling `privatelink_regional_mode` in atlas-aws:** Changes connection strings for every cluster in the project. See [privatelink_regional_mode](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-atlas-aws#privatelink_regional_mode) in the atlas-aws README.
- **Changing the cluster `name` or `project_id`:** Both force replacement. The plan shows `must be replaced`, and applying it deletes the cluster and its data. Create a new cluster and migrate the data instead.
- **Moving a project to another organization (`org_id`):** Forces replacement of the project. Changing only the project `name` is an in-place update.
- **Switching from `regions` to `replication_specs`:** Follow the migration steps in the [cluster topology guide](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-cluster/blob/main/docs/cluster_topology.md). The plan should show no changes after migration.
- **Upgrading a module version:** New defaults can show up as plan changes. See [Upgrade and plan surprises](./debug.md#upgrade-and-plan-surprises).

## Changes you did not make (drift)

A plan can show `~` lines when your configuration did not change. Common causes:

- **Edits outside Terraform:** Someone changed a setting in the Atlas UI, the Atlas CLI, or the AWS console. The plan reverts it to what `main.tf` says. If the change should stay, update `main.tf` to match.
- **Computed values:** After adding a region, attributes such as `connection_strings` or `disk_iops` show `(known after apply)` or `-> null`. Atlas recalculates them; no action is needed.
- **Auto-scaling:** With the `regions` input and auto-scaling enabled, the cluster module reads the current instance sizes from Atlas and keeps them, so auto-scaling events do not show as drift. See [Configuration Persistence with Auto-scaling](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-cluster/blob/main/docs/cluster_topology.md#configuration-persistence-with-auto-scaling). If you see `instance_size` changes you did not make, check whether you set `instance_size` manually for that region.
- **`has changed` notes:** Lines under `Terraform detected the following changes made outside of Terraform` are informational. They show what the refresh found, not what the apply changes.

To see only what changed outside Terraform, without proposing changes:

```sh
terraform plan -refresh-only
```

## Replacements when nothing changed

A plan can show `must be replaced` on a resource whose configuration did not change. A common cause: the resource uses a value from a data source that Terraform could not read during plan.

Normally Terraform reads data sources during plan. When a data source depends on a resource that is being created or changed in the same apply, the read is deferred to apply and its attributes become `(known after apply)`:

```text
module.atlas_aws.data.aws_subnet.privatelink["us-east-1"] will be read during apply
  # (depends on a resource or a module with changes pending)
```

If a deferred value feeds an attribute that forces replacement, the plan shows a replacement even though the real inputs did not change. What to check:

- **Pass values by reference instead of looking them up.** If your root module already creates the VPC, pass the module's outputs as inputs instead of letting the module look the values up itself, and avoid a `depends_on` that only orders the modules. Which value to pass depends on the module's inputs: the walkthrough passes `subnet_ids` from the vpc module output into atlas-aws, which then reads the subnet and VPC data itself; modules that expose a `vpc_id` input take that instead.
- **Avoid `depends_on` on a `module` block.** It applies to every resource and data source inside the module, so one ordering dependency can defer unrelated lookups. Passing an output as an input orders the modules instead.
- **A deferred read on its own is harmless.** Check what consumes it: outputs and in-place attributes are fine; `# forces replacement` is not.

In the walkthrough, the data source reads marked `will be read during apply` are expected: they run while the network is being created, and the plans show `0 to destroy`. When you see a deferred read, check its consumer the same way before assuming a problem.

## Debug a plan diff with provider logs

When a plan shows a change you cannot explain, the provider's debug log names the attributes it sees as changed:

1. Point the logs at a file and run a plan:

   ```sh
   export TF_LOG=DEBUG
   export TF_LOG_PATH=plan.log
   terraform plan
   ```

2. Find what the provider detected as changed:

   ```sh
   grep "Detected value change" plan.log
   ```

3. Read `tf_attribute_path` and `tf_resource_type` from each hit:

   ```text
   ... Detected value change between proposed new state and prior state: ... tf_attribute_path=tags tf_resource_type=mongodbatlas_project ...
   ```

   This example is from a run where only the `tags` map changed: the provider reports the root-level `tags` attribute on the project and cluster resources.

Two limitations to keep in mind:

- **The path is usually the root-level attribute** (`tags`, `replication_specs`, `regions`), not the nested key that actually changed. Use it to find the resource and the top-level attribute, then read the corresponding `~` block in the plan for the nested detail.
- **Field order inside the log line varies.** Grep for the phrase `Detected value change`, not for `tf_attribute_path`.

For the other logging options, see [Logging](./debug.md#logging).

## Errors on apply

### `PRIVATE_ENDPOINT_SERVICE_ALREADY_EXISTS_FOR_REGION`

```text
Error: error creating MongoDB Private Endpoints Connection: ... HTTP 409 Conflict
(Error code: "PRIVATE_ENDPOINT_SERVICE_ALREADY_EXISTS_FOR_REGION")
Detail: A private endpoint service already exists for AWS region US_EAST_1.
```

The Atlas project already has a PrivateLink endpoint service for that region, but Terraform does not track it. This happens when resources are removed from state, or a previous apply or destroy stopped partway.

First check that no other Terraform state or workspace manages the endpoint: if it does, plan and destroy or change it in that state instead of importing it here. Importing the endpoint into two states makes both manage it, and a later destroy or change in either can break the other deployment. Only import after confirming this state owns it.

Import the existing endpoint service instead of creating it:

1. Find the private link ID (a 24-character hex ID) in the Atlas UI under **Network Access > Private Endpoint**, or with the [Atlas CLI](https://www.mongodb.com/docs/atlas/cli/current/):

   ```sh
   atlas privateEndpoints aws list --projectId {project_id}
   ```

2. Import it. The ID format is `{project_id}-{private_link_id}-AWS-{aws_region}`:

   ```sh
   terraform import 'module.atlas_aws.mongodbatlas_privatelink_endpoint.this["us-east-1"]' \
     {project_id}-{private_link_id}-AWS-us-east-1
   ```

3. Run `terraform plan` again. The endpoint service no longer shows as `will be created`.

The AWS endpoint service name (`com.amazonaws.vpce.us-east-1.vpce-svc-...`) is not the import ID.

## What to collect before asking for help

- The plan as text: `terraform plan -no-color -out=plan.tfplan`, then `terraform show -no-color plan.tfplan`.
- The plan as JSON for exact attribute values: `terraform show -json plan.tfplan`.
- Only the resource blocks that surprise you, with IDs, hostnames, and secrets redacted.
- Versions and the rest of the checklist in [Narrow down your configuration](./debug.md#narrow-down-your-configuration).

## Further reading

- [Project, PrivateLink, and cluster walkthrough](../examples/aws-project-privatelink-cluster/README.md)
- [Debug guide](./debug.md)
- [Getting started](./getting-started.md)
- [Terraform plan command](https://developer.hashicorp.com/terraform/cli/commands/plan)
