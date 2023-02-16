variable "user_names" {
  description = "Create IAM useres with these names"
  type        = list(string)
  default     = ["neo", "trinity", "morpheus"]
}

# Loop with count
resource "aws_iam_user" "example_count" {
  count = length(var.user_names)
  name  = var.user_names[count.index]
}

output "user_arns" {
  value       = aws_iam_user.example_count.arn
  description = "The ARN of the crated IAM user"
}

# Loop with for_each
resource "aws_iam_user" "example_for_each" {
  for_each = toset(var.user_names)
  name     = each.key
}

output "all_users" {
  value = aws_iam_user.example_for_each
}
