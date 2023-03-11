provider "aws" {
    region = "eu-west-3"
}

module "alb" {
    source = "../../modules/networking/alb"

    alb_name = "terraform-up-and-running"
    subnet_ids = data.aws_subnets.default.id
}