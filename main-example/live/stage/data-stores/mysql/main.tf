provider "aws" {
  region = "us-west-3"
}

module "database" {
  source = "../../../modules/data-stores/mysql"

  db_username = "<TO_BE_DEFINED>"
  db_password = "<TO_BE_DEFINED>"
}