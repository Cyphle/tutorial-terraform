resource "aws_launch_configuration" "aninstance" {
  image_id        = "ami-0ca5ef73451e16dc1"
  instance_type   = var.instance_type
  security_groups = [aws_security_group.mysg.id]

  user_data = templatefile("user-data.sh", {
    server_port = var.server_port
    # Use databse state defined in data-stores/mysql and linked with remote state source defined in elb
    db_address  = data.terraform_remote_state.db_instance.outputs.address
    db_port     = data.terraform_remote_state.db_instance.outputs.port
  })

  # Required when using a launch configuration with an ASG
  # As Terraform is immutable, if any change is applied, it will delete everything. As it is monitored by ASG
  # use lifecycle settings to tell Terraform to create new things before deleting old ones.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "mysg" {
  name = "${var.cluster_name}-instance"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
