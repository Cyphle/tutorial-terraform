provider "aws" {
  region = "eu-west-3"
}

variable "server_port" {
  description = "The port of the server will use for HTTP requests"
  type = number
  default = 8080
}

# Create a single instance
resource "aws_instance" "MyFirstInstance" {
  ami           = "ami-0ca5ef73451e16dc1"
  instance_type = "t2.micro"
  # aws_security_group.instance.id reference l'id du security group de l'instance
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = <<-EOF
        #!/bin/bash
        echo "Hello, World" > index.html
        nohup busybox httpd -f -p ${var.server_port} &
        EOF

  user_data_replace_on_change = true

  tags = {
    Name = "terraform_example"
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Output variable. After finishing script, it prints this. Can also but requested.
output "public_ip" {
  value = aws_instance.MyFirstInstance.public_ip
  description = "The public IP address of the web server"
}