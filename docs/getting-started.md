# Getting started

This guide covers your first Terraform apply with the terraform-mongodbatlas-modules organization. For the official MongoDB walkthrough of these modules, see [Deploy MongoDB Atlas with Terraform Modules](https://www.mongodb.com/docs/atlas/terraform-modules-landing-zone/). For provider basics, see [Get started with Terraform and the MongoDB Atlas provider](https://www.mongodb.com/docs/atlas/terraform/).

## Prerequisites

- A MongoDB Atlas organization (or permission to create one). See [Atlas organizations](https://www.mongodb.com/docs/atlas/tutorial/manage-organizations/).
- Atlas programmatic credentials (see below). See [Configure API access](https://www.mongodb.com/docs/atlas/configure-api-access/).
- [Terraform](https://developer.hashicorp.com/terraform/install) 1.10 or newer (matches current module requirements).
- Cloud-provider credentials if you use a cloud integration module (AWS, Azure, or GCP).

## Credentials

The [MongoDB Atlas Terraform provider](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs) authenticates with Atlas programmatic credentials.

MongoDB recommends [Atlas Service Accounts](https://www.mongodb.com/docs/atlas/configure-api-access/#grant-programmatic-access-to-an-organization) for Terraform and other automation. Export the client ID and secret:

```sh
export MONGODB_ATLAS_CLIENT_ID="<your-client-id>"
export MONGODB_ATLAS_CLIENT_SECRET="<your-client-secret>"
```

Alternatively, use an [API key pair](https://www.mongodb.com/docs/atlas/configure-api-access/#std-label-create-org-api-key):

```sh
export MONGODB_ATLAS_PUBLIC_API_KEY="<your-public-key>"
export MONGODB_ATLAS_PRIVATE_API_KEY="<your-private-key>"
```

Configure the provider block directly only when environment variables are not an option (avoid committing secrets). See the [provider authentication docs](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs#authentication).

## Which module to start with

Modules stack in a typical landing-zone order described in the [Architecture Center hierarchy guidance](https://www.mongodb.com/docs/atlas/architecture/current/hierarchy/):

1. **Organization** ([terraform-mongodbatlas-organization](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-organization)): Atlas organization settings and resource policies when you manage the Atlas organization with Terraform.
2. **Project** ([terraform-mongodbatlas-project](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-project)): Atlas projects: settings, limits, access lists, and alerts.
3. **Cloud integration** (pick one): [AWS](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-atlas-aws), [Azure](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-atlas-azure), or [GCP](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-atlas-gcp) for private connectivity (PrivateLink or Private Service Connect), cloud-provider access, encryption at rest, and backup export. Set this up alongside your project, before your first cluster.
4. **Cluster** ([terraform-mongodbatlas-cluster](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-cluster)): Replica sets and sharded clusters.

- **Starting from scratch:** You can compose all layers in one root module or split by team ownership.
- **Working with an existing Atlas organization:** Import or reference existing Atlas IDs; start at the layer that matches what is already in Atlas.

See the [organization profile repository table](../profile/README.md#repositories) and [Architecture Center hierarchy](https://www.mongodb.com/docs/atlas/architecture/current/hierarchy/) for what each repository owns.

## Runnable path: project, PrivateLink, and cluster walkthrough

Start with the [project, PrivateLink, and cluster walkthrough](../examples/aws-project-privatelink-cluster/README.md). It combines the project, atlas-aws, and cluster modules at `~> 1.0` in a single `main.tf` with no variables. Step 1 deploys a single-region sharded cluster over AWS PrivateLink. Step 2 adds a second region, and the README shows each configuration change next to the plan it produces, so you can compare your own plan against a verified run.

## Runnable path: atlas-examples

The fastest way to see a full stack is [atlas-examples](https://github.com/terraform-mongodbatlas-modules/atlas-examples). Each cloud has a complete example with its own README:

- [AWS complete example](https://github.com/terraform-mongodbatlas-modules/atlas-examples/tree/main/aws/atlas-aws-module-complete)
- [Azure complete example](https://github.com/terraform-mongodbatlas-modules/atlas-examples/tree/main/azure/atlas-azure-module-complete)
- [GCP complete example](https://github.com/terraform-mongodbatlas-modules/atlas-examples/tree/main/gcp/atlas-gcp-module-complete)

Follow the README in the example directory for prerequisites, `terraform.tfvars`, and apply steps. Examples are reference implementations, not production templates.

## Runnable path: one-apply chatbot demo

For a single apply that results in a running application, see the [chatbot demo](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-aws-chatbot) ([Registry](https://registry.terraform.io/modules/terraform-mongodbatlas-modules/aws-chatbot/mongodbatlas/latest)). This demo brings together the modules on this page to deploy a hybrid search chatbot on AWS, using Atlas over PrivateLink, a private ECS Fargate service, and CloudFront at the edge. Like `atlas-examples`, this is a demo and carries no stability guarantee.

## Versioning

Each module is **generally available (GA)** and formally supported by MongoDB, including bug fixes, security patches, and backward-compatible enhancements. See the stability commitment in each module README (for example the project module's two-year v1 stability window).

The module set is released at **v1.0.0**. Use `~> 1.0` to receive v1 minor and patch releases; do not leave `version` unset in production root modules. If you are on a 0.x version, read the module's v1.0.0 upgrade guide before switching.

Always use a **pessimistic constraint (`~>`)** in your root module for:

- Every `terraform-mongodbatlas-modules/*` `module` block
- The `mongodbatlas` provider in `required_providers`
- The cloud provider (`aws`, `azurerm`, or `google`) when you use a cloud integration module

Example for a project module:

```hcl
terraform {
  required_version = ">= 1.10"

  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 2.15"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

module "atlas_project" {
  source  = "terraform-mongodbatlas-modules/project/mongodbatlas"
  version = "~> 1.0"

  # ... module inputs
}
```

Replace `project` with the module you need and match provider minor lines to what that module README lists in `versions.tf`. Each module README and upgrade guide documents supported provider ranges and migration steps when you bump versions.

Commit `.terraform.lock.hcl` so CI and teammates resolve the same provider builds.

## Install a module from the Registry

Use the `source` and `version` pattern shown above. Each module README lists required inputs and outputs.

## Next steps

- [Organization profile repository table](../profile/README.md#repositories) and [Architecture Center](https://www.mongodb.com/docs/atlas/architecture/current/): Module boundaries and design guidance.
- Module README and upgrade guide in the repo you are using.
- [Debug guide](./debug.md): Logging, triage, and where to file issues.
- [Troubleshooting plan changes](./troubleshooting.md): Reading plans, safe vs risky changes, and drift.
- [Support](../SUPPORT.md): Atlas Support for contracted customers.
- [Atlas Architecture Center](https://www.mongodb.com/docs/atlas/architecture/current/): Landing zone, security, HA, and automation guidance that informs module defaults.
- [Guidance for automated infrastructure provisioning](https://www.mongodb.com/docs/atlas/architecture/current/automation/): How Terraform fits alongside other Atlas automation options.
