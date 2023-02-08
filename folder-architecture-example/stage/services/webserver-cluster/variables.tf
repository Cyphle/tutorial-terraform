variable "server_port" {
  description = "The port of the server will use for HTTP requests"
  type        = number
  default     = 8080
}

# Data sources are used to get information from AWS
data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnets" "subnets_in_default_vpc" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
}
