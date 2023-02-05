provider "aws" {
  region = "eu-west-3"
}

# Terraform backend
terraform {
  backend "s3" {
    bucket = "terraform-cyphle-state-tutorial"
    # Nom du fichier state
    key = "global/s3/terraform.tfstate"
    region = "eu-west-3"

    dynamodb_table = "terraform-cyphle-state-locks"
    encrypt = true
  }
}

variable "server_port" {
  description = "The port of the server will use for HTTP requests"
  type        = number
  default     = 8080
}

# Data sources are used to get information from AWS
data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnets" "subnets_in_default_vpc" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
}

output "alb_dns_name" {
  value       = aws_lb.my_alb.dns_name
  description = "The domain name of the load balancer"
}
