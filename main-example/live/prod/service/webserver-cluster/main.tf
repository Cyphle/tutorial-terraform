provider "aws" {
  region = "eu-west-3"

  # Tags to apply to all resources by default
  default_tags {
    tags = {
      Owner     = "terra-foo"
      ManagedBy = "Terraform"
    }
  }
}

# ref of module
module "webserver_cluster" {
  # Importing the module
  source = "../../../modules/services/webserver-cluster"

  # Inputs of module
  cluster_name           = "webservers-prod"
  db_remote_state_bucket = "mys3bucket"
  db_remote_state_key    = "prod/data-stores/mysql/terraform.state"

  instance_type      = "m4.large"
  min_size           = 2
  max_size           = 10
  enable_autoscaling = true

  custom_tags = {
    Owner     = "team-foo"
    ManagedBy = "terraform"
  }
}

# Example d'utilisation d'un output de module
output "ref_to_module_output" {
  description = "Référence à un output d'un module pour l'utiliser"
  value = module.webserver_cluster.alb_dns_name
}
