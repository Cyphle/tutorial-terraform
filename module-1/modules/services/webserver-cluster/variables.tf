locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}

variable "server_port" {
  description = "The port of the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type        = string
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket for the database's remote state"
  type        = string
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instances to run (e.g. t2.micro)"
  type        = string
}

variable "min_size" {
  decription = "The minimum number of EC2 instances in the ASG"
  type       = number
}

variable "max_size" {
  description = "The maximum number of EC2 instances in the ASG"
  type        = number
}