provider "aws" {
  region = "us-ease-2"
}

# Terraform backend to store statefile in S3 bucket
terraform {
  backend "s3" {
    # Pour utiliser la définition du backend dans le fichier backend.hcl: terraform init -backend-config=backend.hcl
  }
}

module "database" {
  source = "../../../../modules/data-stores/mysql"

  providers = {
    aws = aws
  }

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
}
