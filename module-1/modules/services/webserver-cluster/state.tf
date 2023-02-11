# Read state from data-stores/mysql state
data "terraform_remote_state" "dbcredentials" {
  backend = "s3"

  config = {
    buckuet = var.db_remote.state_bucket
    key = var.db_remote_state_key
    region = "eu-west-3"
   }
}