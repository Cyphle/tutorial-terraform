terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}

# Use of a module
module "webserver_cluster" {
  # Utilisation de repository Github pour importer le module avec une version
  source = "github.com/brikis98/terraform-up-and-running-code/code/terraform/04-terraform-module/module-example/modules/services/webserver-cluster?ref=v0.3.0"

  ami         = data.aws_ami.ubuntu.id
  server_text = "New server test"

  # Input variables of module
  cluster_name           = "webservers-stage"
  environment            = var.environment
  db_remote_state_bucket = var.db_remote_state_bucket
  db_remote_state_key    = var.db_remote_state_key

  instance_type      = "t2.mciro"
  min_size           = 2
  max_size           = 2
  enable_autoscaling = false
}

# Add an inbound rule to ELB
resource "aws_security_group_rule" "allow_testing_inbound" {
  type              = "ingress"
  security_group_id = module.webserver_cluster.alb_security_group_id

  from_port   = 12345
  to_port     = 12345
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

data "aws_ami" "ubuntu" {
  provider = aws.region_1

  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}
