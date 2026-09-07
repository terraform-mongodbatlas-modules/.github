# Getting started

This guide covers your first Terraform apply with the terraform-mongodbatlas-modules organization.

## Prerequisites

- A MongoDB Atlas organization (or permission to create one).
- Atlas API credentials (see below).
- [Terraform](https://developer.hashicorp.com/terraform/install) 1.9 or newer (matches current module requirements).
- Cloud-provider credentials if you use a CSP integration module (AWS, Azure, or GCP).

## Credentials

The [MongoDB Atlas Terraform provider](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs) authenticates with API keys.

1. In Atlas, create an API key with the roles your modules need (organization or project level).
2. Export the key pair:

```sh
export MONGODB_ATLAS_PUBLIC_KEY="<your-public-key>"
export MONGODB_ATLAS_PRIVATE_KEY="<your-private-key>"
```

Alternatively, configure the provider block directly (avoid committing secrets). See the [provider authentication docs](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs#authentication).

## Which module to start with

Modules stack in a typical landing-zone order:

1. **Organization** ([terraform-mongodbatlas-organization](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-organization)): Org-level settings when you manage the Atlas org with Terraform.
2. **Project** ([terraform-mongodbatlas-project](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-project)): Projects, project IAM, and alerts.
3. **Cluster** ([terraform-mongodbatlas-cluster](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-cluster)): Replica sets and sharded clusters.
4. **Cloud integration** (pick one): [AWS](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-atlas-aws), [Azure](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-atlas-azure), or [GCP](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-atlas-gcp) for private endpoints, peering, and related CSP resources.

- **Greenfield:** You can compose all layers in one root module or split by team ownership.
- **Brownfield:** Import or reference existing Atlas IDs; start at the layer that matches what is already in Atlas.

See [repos.md](./repos.md) for what each repository owns.

## Runnable path: atlas-examples

The fastest way to see a full stack is [atlas-examples](https://github.com/terraform-mongodbatlas-modules/atlas-examples). Each cloud has a complete example with its own README:

- [AWS complete example](https://github.com/terraform-mongodbatlas-modules/atlas-examples/tree/main/aws/atlas-aws-module-complete)
- [Azure complete example](https://github.com/terraform-mongodbatlas-modules/atlas-examples/tree/main/azure/atlas-azure-module-complete)
- [GCP complete example](https://github.com/terraform-mongodbatlas-modules/atlas-examples/tree/main/gcp/atlas-gcp-module-complete)

Follow the README in the example directory for prerequisites, `terraform.tfvars`, and apply steps. Examples are reference implementations, not production templates.

## Install a module from the Registry

Pin a module version in your root module:

```hcl
module "atlas_project" {
  source  = "terraform-mongodbatlas-modules/project/mongodbatlas"
  version = "~> 1.0"

  # ... module inputs
}
```

Replace `project` with the module you need. Each module README lists required inputs and outputs.

## Next steps

- [Repository map](./repos.md): Boundaries between modules.
- Module README and upgrade guide in the repo you are using.
- [Debug guide](./debug.md): Logging, triage, and where to file issues.
- [Support](../SUPPORT.md): Atlas Support for contracted customers.
