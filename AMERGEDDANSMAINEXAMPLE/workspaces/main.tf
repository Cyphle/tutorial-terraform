provider "aws" {
  region = "eu-west-3"
}

# Terraform backend
terraform {
  backend "s3" {
    bucket = "terraform-cyphle-state-tutorial"
    # Nom du fichier state
    key = "workspaces-example/terraform.tfstate"
    region = "eu-west-3"

    dynamodb_table = "terraform-cyphle-state-locks"
    encrypt = true
  }
}

resource "aws_instance" "instance" {
  ami           = "ami-0ca5ef73451e16dc1"
  # Set instance type depending on current workspace
  instance_type = terraform.workspace == "default" ? "t2.medium" : "t2.micro"
}