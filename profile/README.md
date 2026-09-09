# terraform-mongodbatlas-modules

Official [Terraform Registry](https://registry.terraform.io/namespaces/terraform-mongodbatlas-modules) modules for deploying MongoDB Atlas landing zones: organization settings, projects, clusters, and cloud-provider networking integrations.

## Why use these modules

- **Opinionated defaults** for common Atlas landing-zone patterns across AWS, Azure, and GCP.
- **Registry-published** modules with versioned releases and upgrade guides per repo.
- **Stability commitment:** MongoDB formally supports each module with bug fixes, security patches, and backward-compatible enhancements; v1 releases carry a two-year no-breaking-changes stability window (see each module README).
- **Semantic versioning:** breaking changes land only in new major versions, so minor and patch upgrades keep your configuration working; pin with pessimistic constraints (`~>`) and upgrade on your schedule.
- **Runnable examples** in [atlas-examples](https://github.com/terraform-mongodbatlas-modules/atlas-examples) you can copy and adapt.
- **Aligned with MongoDB guidance** in the [Atlas Architecture Center](https://www.mongodb.com/docs/atlas/architecture/current/) and [Deploy MongoDB Atlas with Terraform Modules](https://www.mongodb.com/docs/atlas/terraform-modules-landing-zone/) guide.

## Who should read what

- **Developers and platform engineers deploying Atlas with Terraform:** Start with [Getting started](../docs/getting-started.md), then the module README for the layer you are deploying. Use [atlas-examples](https://github.com/terraform-mongodbatlas-modules/atlas-examples) for a full stack walkthrough. For design patterns, see the [Architecture Center](https://www.mongodb.com/docs/atlas/architecture/current/) and [Solutions Library](https://www.mongodb.com/docs/atlas/architecture/current/solutions-library/).
- **Planning a landing zone:** Use the [repository table](#repositories) below for what each module covers, [landing zone](https://www.mongodb.com/docs/atlas/architecture/current/landing-zone/) and [hierarchy](https://www.mongodb.com/docs/atlas/architecture/current/hierarchy/) guidance when planning scope, and each module's upgrade guide when planning version bumps.
- **Debugging a deployment:** [Debug guide](../docs/debug.md) covers logging, how to tell provider issues from module issues, and where to report a bug.

## Repositories

Modules map to the [Atlas org, project, and cluster hierarchy](https://www.mongodb.com/docs/atlas/architecture/current/hierarchy/) in the Architecture Center. Use [landing zone](https://www.mongodb.com/docs/atlas/architecture/current/landing-zone/) guidance when scoping a greenfield deployment. For industry reference architectures, see the [Solutions Library](https://www.mongodb.com/docs/atlas/architecture/current/solutions-library/).

Each module owns one layer of that stack. Use one CSP integration repo (AWS, Azure, or GCP) for cloud-provider access, private connectivity (PrivateLink or Private Service Connect), encryption at rest, and backup export on your cloud. Module READMEs link Architecture Center pages when defaults trace to that guidance (for example backups, TLS, or autoscaling). **Upgrade guides** stay in each module repo; read them before bumping `version` constraints.

| Repository | Registry | Role |
|------------|----------|------|
| [terraform-mongodbatlas-organization](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-organization) | [organization](https://registry.terraform.io/modules/terraform-mongodbatlas-modules/organization/mongodbatlas/latest) | Atlas organizations (`create` submodule) and org resource policies (`existing` submodule) |
| [terraform-mongodbatlas-project](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-project) | [project](https://registry.terraform.io/modules/terraform-mongodbatlas-modules/project/mongodbatlas/latest) | Atlas projects: settings, limits, maintenance window, IP access list, backup compliance policy, log integrations, default alerts |
| [terraform-mongodbatlas-cluster](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-cluster) | [cluster](https://registry.terraform.io/modules/terraform-mongodbatlas-modules/cluster/mongodbatlas/latest) | Atlas clusters: replica-set and sharded topologies, autoscaling, backups, advanced configuration |
| [terraform-mongodbatlas-atlas-aws](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-atlas-aws) | [atlas-aws](https://registry.terraform.io/modules/terraform-mongodbatlas-modules/atlas-aws/mongodbatlas/latest) | Atlas AWS integrations: PrivateLink endpoints, cloud-provider access (IAM role and policy), encryption at rest, backup export, log integration |
| [terraform-mongodbatlas-atlas-azure](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-atlas-azure) | [atlas-azure](https://registry.terraform.io/modules/terraform-mongodbatlas-modules/atlas-azure/mongodbatlas/latest) | Atlas Azure integrations: Private Link, service principal authorization, encryption at rest, backup export, log integration |
| [terraform-mongodbatlas-atlas-gcp](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-atlas-gcp) | [atlas-gcp](https://registry.terraform.io/modules/terraform-mongodbatlas-modules/atlas-gcp/mongodbatlas/latest) | Atlas GCP integrations: Private Service Connect, cloud-provider access, encryption at rest, backup export, log integration |
| [atlas-examples](https://github.com/terraform-mongodbatlas-modules/atlas-examples) | — | End-to-end example stacks per cloud (not a Registry module) |

## Hub documentation

- [Getting started](../docs/getting-started.md): Credentials, first apply, and the examples path.
- [Debug guide](../docs/debug.md): Reproduce configs, logging, provider vs module, where to file issues.

## Support

See [SUPPORT.md](../SUPPORT.md). Contracted Atlas customers should use [MongoDB Atlas Support](https://support.mongodb.com/).

## MongoDB documentation

- [Atlas documentation](https://www.mongodb.com/docs/atlas/)
- [Get started with Terraform and the Atlas provider](https://www.mongodb.com/docs/atlas/terraform/)
- [Deploy MongoDB Atlas with Terraform Modules](https://www.mongodb.com/docs/atlas/terraform-modules-landing-zone/)
- [Atlas Architecture Center](https://www.mongodb.com/docs/atlas/architecture/current/)
