# Atlas project, AWS PrivateLink, and a sharded cluster. Every value is
# hard-coded except `tags`, which has a default.
# Step 1: apply as is (region1 = us-east-1).
# Step 2: uncomment every block marked "STEP 2" (region2 = us-west-2), then plan and apply.
# See README.md for the expected plan at each step.

terraform {
  required_version = ">= 1.10"

  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 2.18"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
  }
}

variable "tags" {
  description = "Tags for the Atlas project, the Atlas cluster, and every AWS resource."
  type        = map(string)
  default = {
    environment = "walkthrough"
    team        = "platform"
  }
}

provider "mongodbatlas" {}

provider "aws" {
  region = "us-east-1"

  # Applies to every AWS resource, including the ones the vpc and atlas-aws modules create.
  default_tags {
    tags = var.tags
  }
}

# --- AWS network: one VPC per region with private subnets in three AZs --------
# Replace these with your existing VPC and subnet IDs if you already have them.

module "vpc_region1" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.7"

  name            = "lz-walkthrough-region1"
  region          = "us-east-1"
  cidr            = "10.10.0.0/16"
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
}

# STEP 2: uncomment (region2 network)
# module "vpc_region2" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "~> 6.7"
#
#   name            = "lz-walkthrough-region2"
#   region          = "us-west-2"
#   cidr            = "10.20.0.0/16"
#   azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
#   private_subnets = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
# }

# --- Atlas modules ------------------------------------------------------------

# Org ID of the Atlas credentials (service account or API key) in use.
data "mongodbatlas_roles_org_id" "current" {}

module "atlas_project" {
  source  = "terraform-mongodbatlas-modules/project/mongodbatlas"
  version = "~> 1.0"

  org_id = data.mongodbatlas_roles_org_id.current.org_id
  name   = "lz-walkthrough"
  tags   = var.tags
}

module "atlas_aws" {
  source  = "terraform-mongodbatlas-modules/atlas-aws/mongodbatlas"
  version = "~> 1.0"

  project_id = module.atlas_project.id

  privatelink_endpoints = [
    {
      region     = "us-east-1"
      subnet_ids = module.vpc_region1.private_subnets
    },
    # STEP 2: uncomment (region2 PrivateLink endpoint)
    # {
    #   region     = "us-west-2"
    #   subnet_ids = module.vpc_region2.private_subnets
    # },
  ]
}

module "atlas_cluster" {
  source  = "terraform-mongodbatlas-modules/cluster/mongodbatlas"
  version = "~> 1.0"

  project_id    = module.atlas_project.id
  name          = "lz-walkthrough"
  provider_name = "AWS"
  cluster_type  = "SHARDED"

  regions = [
    {
      name       = "US_EAST_1"
      node_count = 3
      shard_name = "s1"
    },
    # STEP 2: uncomment (region2 electable nodes in the same shard)
    # {
    #   name       = "US_WEST_2"
    #   node_count = 2
    #   shard_name = "s1"
    # },
  ]

  tags = var.tags
}

output "privatelink" {
  value = module.atlas_aws.privatelink
}

output "connection_strings" {
  value = module.atlas_cluster.connection_strings
}
