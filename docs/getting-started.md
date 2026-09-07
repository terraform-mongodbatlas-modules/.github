# Getting started

This guide covers your first Terraform apply with the terraform-mongodbatlas-modules organization. For the official MongoDB walkthrough of these modules, see [Deploy MongoDB Atlas with Terraform Modules](https://www.mongodb.com/docs/atlas/terraform-modules-landing-zone/). For provider basics, see [Get started with Terraform and the MongoDB Atlas provider](https://www.mongodb.com/docs/atlas/terraform/).

## Prerequisites

- A MongoDB Atlas organization (or permission to create one). See [Atlas organizations](https://www.mongodb.com/docs/atlas/tutorial/manage-organizations/).
- Atlas programmatic credentials (see below). See [Configure API access](https://www.mongodb.com/docs/atlas/configure-api-access/).
- [Terraform](https://developer.hashicorp.com/terraform/install) 1.10 or newer (matches current module requirements).
- Cloud-provider credentials if you use a CSP integration module (AWS, Azure, or GCP).

## Credentials

The [MongoDB Atlas Terraform provider](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs) authenticates with Atlas programmatic credentials.

MongoDB recommends [Atlas Service Accounts](https://www.mongodb.com/docs/atlas/configure-api-access/#grant-programmatic-access-to-an-organization) for Terraform and other automation. Export the client ID and secret:

```sh
export MONGODB_ATLAS_CLIENT_ID="<your-client-id>"
export MONGODB_ATLAS_CLIENT_SECRET="<your-client-secret>"
```

Alternatively, use an [API key pair](https://www.mongodb.com/docs/atlas/configure-api-access/#create-an-api-key):

```sh
export MONGODB_ATLAS_PUBLIC_KEY="<your-public-key>"
export MONGODB_ATLAS_PRIVATE_KEY="<your-private-key>"
```

Configure the provider block directly only when environment variables are not an option (avoid committing secrets). See the [provider authentication docs](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs#authentication).

## Which module to start with

Modules stack in a typical landing-zone order described in the [Architecture Center hierarchy guidance](https://www.mongodb.com/docs/atlas/architecture/current/hierarchy/):

1. **Organization** ([terraform-mongodbatlas-organization](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-organization)): Org-level settings when you manage the Atlas org with Terraform.
2. **Project** ([terraform-mongodbatlas-project](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-project)): Projects, project IAM, and alerts.
3. **Cluster** ([terraform-mongodbatlas-cluster](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-cluster)): Replica sets and sharded clusters.
4. **Cloud integration** (pick one): [AWS](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-atlas-aws), [Azure](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-atlas-azure), or [GCP](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-atlas-gcp) for private endpoints, peering, and related CSP resources.

- **Greenfield:** You can compose all layers in one root module or split by team ownership.
- **Brownfield:** Import or reference existing Atlas IDs; start at the layer that matches what is already in Atlas.

See the [org profile repository table](../profile/README.md#repositories) and [Architecture Center hierarchy](https://www.mongodb.com/docs/atlas/architecture/current/hierarchy/) for what each repository owns.

## Runnable path: atlas-examples

The fastest way to see a full stack is [atlas-examples](https://github.com/terraform-mongodbatlas-modules/atlas-examples). Each cloud has a complete example with its own README:

- [AWS complete example](https://github.com/terraform-mongodbatlas-modules/atlas-examples/tree/main/aws/atlas-aws-module-complete)
- [Azure complete example](https://github.com/terraform-mongodbatlas-modules/atlas-examples/tree/main/azure/atlas-azure-module-complete)
- [GCP complete example](https://github.com/terraform-mongodbatlas-modules/atlas-examples/tree/main/gcp/atlas-gcp-module-complete)

Follow the README in the example directory for prerequisites, `terraform.tfvars`, and apply steps. Examples are reference implementations, not production templates.

## Versioning

Each module is **generally available (GA)** and formally supported by MongoDB, including bug fixes, security patches, and backward-compatible enhancements. See the stability commitment in each module README (for example the project module's two-year v1 stability window once that major line ships).

**v1.0.0** releases across the module set are **coming soon**. Until then, Registry publishes **0.x** versions. Pin the minor line you tested; do not leave `version` unset in production root modules.

Always use a **pessimistic constraint (`~>`)** in your root module for:

- Every `terraform-mongodbatlas-modules/*` `module` block
- The `mongodbatlas` provider in `required_providers`
- The cloud provider (`aws`, `azurerm`, or `google`) when you use a CSP integration module

Example for a project module today (swap `~> 0.3` for `~> 1.0` after the v1 line is published):

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
  version = "~> 0.3"

  # ... module inputs
}
```

Replace `project` with the module you need and match provider minor lines to what that module README lists in `versions.tf`. Each module README and upgrade guide documents supported provider ranges and migration steps when you bump versions.

Commit `.terraform.lock.hcl` so CI and teammates resolve the same provider builds.

## Install a module from the Registry

Use the `source` and `version` pattern shown above. Each module README lists required inputs and outputs.

## Next steps

- [Org profile repository table](../profile/README.md#repositories) and [Architecture Center](https://www.mongodb.com/docs/atlas/architecture/current/): Module boundaries and design guidance.
- Module README and upgrade guide in the repo you are using.
- [Debug guide](./debug.md): Logging, triage, and where to file issues.
- [Support](../SUPPORT.md): Atlas Support for contracted customers.
- [Atlas Architecture Center](https://www.mongodb.com/docs/atlas/architecture/current/): Landing zone, security, HA, and automation guidance that informs module defaults.
- [Guidance for automated infrastructure provisioning](https://www.mongodb.com/docs/atlas/architecture/current/automation/): How Terraform fits alongside other Atlas automation options.
