# Definition of remote state
data "terraform_remote_state" "db_instance" {
  # Reference backend named s3
  backend = "s3"

  config = {
    bucket = var.db_remote_state_bucket
    key    = var.db_remote_state_key
    region = "eu-west-3"
  }
}
