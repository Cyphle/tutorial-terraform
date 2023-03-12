bucket = "terraform-up-and-running-state"
key    = "stage/data-stores/mysql/terraform.tfstate"
region = "eu-west-3"

dynamodb_table = "terrform-up-and-running-locks"
encrypt        = true