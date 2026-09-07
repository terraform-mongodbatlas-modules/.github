# terraform-mongodbatlas-modules

Official [Terraform Registry](https://registry.terraform.io/namespaces/terraform-mongodbatlas-modules) modules for deploying MongoDB Atlas landing zones: organization settings, projects, clusters, and cloud-provider networking integrations.

## Why use these modules

- **Opinionated defaults** for common Atlas landing-zone patterns across AWS, Azure, and GCP.
- **Registry-published** modules with versioned releases and upgrade guides per repo.
- **Runnable examples** in [atlas-examples](https://github.com/terraform-mongodbatlas-modules/atlas-examples) you can copy and adapt.

## Who should read what

- **Customers and SAs:** Start with [Getting started](../docs/getting-started.md), then the module README for the layer you are deploying. Use [atlas-examples](https://github.com/terraform-mongodbatlas-modules/atlas-examples) for a full stack walkthrough.
- **Solutions architects:** [Repository map](../docs/repos.md) for ownership boundaries; module upgrade guides when planning version bumps.
- **TSE:** Public triage steps live in [Debug guide](../docs/debug.md). Internal pocket content links here; it does not duplicate getting started.

## Repositories

| Repository | Registry | Role |
|------------|----------|------|
| [terraform-mongodbatlas-organization](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-organization) | [organization](https://registry.terraform.io/modules/terraform-mongodbatlas-modules/organization/mongodbatlas/latest) | Atlas organization settings |
| [terraform-mongodbatlas-project](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-project) | [project](https://registry.terraform.io/modules/terraform-mongodbatlas-modules/project/mongodbatlas/latest) | Atlas projects and project IAM |
| [terraform-mongodbatlas-cluster](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-cluster) | [cluster](https://registry.terraform.io/modules/terraform-mongodbatlas-modules/cluster/mongodbatlas/latest) | Atlas clusters |
| [terraform-mongodbatlas-atlas-aws](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-atlas-aws) | [atlas-aws](https://registry.terraform.io/modules/terraform-mongodbatlas-modules/atlas-aws/mongodbatlas/latest) | Atlas AWS integrations |
| [terraform-mongodbatlas-atlas-azure](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-atlas-azure) | [atlas-azure](https://registry.terraform.io/modules/terraform-mongodbatlas-modules/atlas-azure/mongodbatlas/latest) | Atlas Azure integrations |
| [terraform-mongodbatlas-atlas-gcp](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-atlas-gcp) | [atlas-gcp](https://registry.terraform.io/modules/terraform-mongodbatlas-modules/atlas-gcp/mongodbatlas/latest) | Atlas GCP integrations |
| [atlas-examples](https://github.com/terraform-mongodbatlas-modules/atlas-examples) | — | End-to-end example stacks (not a Registry module) |

## Hub documentation

- [Getting started](../docs/getting-started.md): Credentials, first apply, and the examples path.
- [Repository map](../docs/repos.md): What each repo owns and does not own.
- [Debug guide](../docs/debug.md): Reproduce configs, logging, provider vs module, where to file issues.

## Support

See [SUPPORT.md](../SUPPORT.md). Contracted Atlas customers should use [MongoDB Atlas Support](https://support.mongodb.com/).
