# TODO modulariser ca

provider "aws" {
  region = "us-west-3"
}

terraform {
  backend "s3" {
    bucket = "terraform-up-and-running-state"
    key = "stage/data-stores/mysql/terraform.tfstate"
    region = "eu-west-3"

    dynamodb_table = "terrform-up-and-running-locks"
    encrypt = true
  }
}

resource "aws_db_instance" "sqldb" {
  identifier_prefix   = "terraform-up-and-running"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"
  skip_final_snapshot = true
  db_name             = "example_database"

  username = var.db_username
  password = var.db_password
}
