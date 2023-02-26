provider "aws" {
  region = "eu-west-3"
}

# ref of module
module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  # Inputs of module
  cluster_name           = "webservers-prod"
  db_remote_state_bucket = "mys3bucket"
  db_remote_state_key    = "prod/data-stores/mysql/terraform.state"

  instance_type      = "m4.large"
  min_size           = 2
  max_size           = 10
  enable_autoscaling = true
}

