provider "aws" {
  region = "eu-west-3"
}

# Use of a module
module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  # Input variables of module
  cluster_name           = "webservers-stage"
  db_remote_state_bucket = "mys3bucket"
  db_remote_state_key    = "stage/date-stores/mysql_terraform.tfstate"

  instance_type = "t2.mciro"
  min_size      = 2
  max_size      = 2
}
