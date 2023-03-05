provider "aws" {
  region = "us-ease-2"
}

module "database" {
  source = "../../../../modules/data-stores/mysql"

  providers = {
    aws = aws
  }

  db_name     = "staging_db"
  db_username = var.db_username
  db_password = var.db_password
}
