provider "aws" {
  region = "us-ease-2"
  alias  = "parent"
}

provider "aws" {
  region = "us-east-2"
  alias  = "child"

  assume_role {
    role_arn = "arn:aws:iam::2222222:role/OrganizationAccountAccessRole"
  }
}

module "multi_account_example" {
  source = "../../modules/multi-account"

  # Pass providers aliases that are required by module
  providers = {
    aws.parent = aws.parent
    aws.child  = aws.child
  }
}
