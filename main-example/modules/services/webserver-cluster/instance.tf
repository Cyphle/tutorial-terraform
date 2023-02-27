resource "aws_launch_configuration" "aninstance" {
  image_id      = var.ami
  instance_type = var.instance_type
  # Workspace: Il est possible d'avoir des workspace Terraform pour configurer différemment
  # instance_type = terraform.workspace == "default" ? "t2.medium" : "t2.micro"
  security_groups = [aws_security_group.mysg.id]

  user_data = templatefile("${path.module}/user-data.sh", {
    server_port = var.server_port
    # Use databse state defined in data-stores/mysql and linked with remote state source defined in state
    db_address  = data.terraform_remote_state.db_instance.outputs.address
    db_port     = data.terraform_remote_state.db_instance.outputs.port
    server_text = var.server_text
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
