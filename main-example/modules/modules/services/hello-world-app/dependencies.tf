locals {
  mysql_config = (
    var.mysql_config == null
      ? data.terraform_remote_state.db_instance[0].outputs
      : var.mysql_config
  )

  vpc_id = (
    var.vpc_id == null
       ? data.aws_vpc.default_vpc[0].id
       : var.vpc_id
  )

  subnet_ids = (
    var.subnet_ids == null
      ? data.aws_subnets.subnets_in_default_vpc[0].ids
      : var.subnet_ids
  )
}

# Definition of remote state
data "terraform_remote_state" "db_instance" {
  count = var.mysql_config == null ? 1 : 0

  # Reference backend named s3
  backend = "s3"

  config = {
    bucket = var.db_remote_state_bucket
    key    = var.db_remote_state_key
    region = "eu-west-3"
  }
}

# Data sources are used to get information from AWS
data "aws_vpc" "default_vpc" {
  count = var.vpc_id == null ? 1 : 0
  default = true
}

data "aws_subnets" "subnets_in_default_vpc" {
  count = var.subnet_ids == null ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
}