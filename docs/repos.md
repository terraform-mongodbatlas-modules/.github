# Repository map

Seven public repositories make up the terraform-mongodbatlas-modules organization. Each module is published on the [Terraform Registry](https://registry.terraform.io/namespaces/terraform-mongodbatlas-modules).

## terraform-mongodbatlas-organization

- **GitHub:** [terraform-mongodbatlas-organization](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-organization)
- **Registry:** [organization/mongodbatlas](https://registry.terraform.io/modules/terraform-mongodbatlas-modules/organization/mongodbatlas/latest)
- **Owns:** Atlas organization settings, org-level IAM, org-wide configuration.
- **Does not own:** Projects, clusters, or cloud-provider networking.

## terraform-mongodbatlas-project

- **GitHub:** [terraform-mongodbatlas-project](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-project)
- **Registry:** [project/mongodbatlas](https://registry.terraform.io/modules/terraform-mongodbatlas-modules/project/mongodbatlas/latest)
- **Owns:** Atlas projects, project IAM, alerts, and project-level settings.
- **Does not own:** Clusters or CSP-specific VPC, peering, or private endpoint resources.

## terraform-mongodbatlas-cluster

- **GitHub:** [terraform-mongodbatlas-cluster](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-cluster)
- **Registry:** [cluster/mongodbatlas](https://registry.terraform.io/modules/terraform-mongodbatlas-modules/cluster/mongodbatlas/latest)
- **Owns:** Atlas clusters (replica set and sharded topologies), cluster options exposed by the module.
- **Does not own:** CSP networking modules; use the AWS, Azure, or GCP integration repo for your cloud.

## terraform-mongodbatlas-atlas-aws

- **GitHub:** [terraform-mongodbatlas-atlas-aws](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-atlas-aws)
- **Registry:** [atlas-aws/mongodbatlas](https://registry.terraform.io/modules/terraform-mongodbatlas-modules/atlas-aws/mongodbatlas/latest)
- **Owns:** Atlas AWS private endpoints, IAM roles and policies for Atlas on AWS, VPC peering and related AWS resources defined by the module.
- **Does not own:** Azure or GCP resources; Atlas project or cluster resources (use project and cluster modules).

## terraform-mongodbatlas-atlas-azure

- **GitHub:** [terraform-mongodbatlas-atlas-azure](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-atlas-azure)
- **Registry:** [atlas-azure/mongodbatlas](https://registry.terraform.io/modules/terraform-mongodbatlas-modules/atlas-azure/mongodbatlas/latest)
- **Owns:** Atlas Azure private endpoints, VNet integration, and related Azure resources defined by the module.
- **Does not own:** AWS or GCP resources; Atlas project or cluster resources.

## terraform-mongodbatlas-atlas-gcp

- **GitHub:** [terraform-mongodbatlas-atlas-gcp](https://github.com/terraform-mongodbatlas-modules/terraform-mongodbatlas-atlas-gcp)
- **Registry:** [atlas-gcp/mongodbatlas](https://registry.terraform.io/modules/terraform-mongodbatlas-modules/atlas-gcp/mongodbatlas/latest)
- **Owns:** Atlas GCP private endpoints, VPC peering, and related GCP resources defined by the module.
- **Does not own:** AWS or Azure resources; Atlas project or cluster resources.

## atlas-examples

- **GitHub:** [atlas-examples](https://github.com/terraform-mongodbatlas-modules/atlas-examples)
- **Registry:** Not published as a module.
- **Owns:** End-to-end example root modules per cloud provider.
- **Does not own:** Module source code; examples are starting points, not production templates.

## Upgrade guides

Each module repository ships its own upgrade guide (for example `docs/v1-upgrade-guide.md` or the path listed in that repo's README). Read the guide for the module and version you are moving to; do not copy migration steps into this hub.
