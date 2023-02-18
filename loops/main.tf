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

# Loop with for
output "upper_names" {
  value = [for name in var.names : upper(name) if length(name) < 5]
}

variable "hero_thousand_faces" {
  desription = "map"
  type       = map(string)
  default = {
    neo      = "hero"
    trinity  = "love interest"
    morpheus = "monter"
  }
}

output "bios" {
  value = [for name, role in var.hero_thousand_faces : "${name} is the ${role}"]
}

output "upper_roles" {
  value = { for name, role in var.hero_thousand_faces : upper(name) => upper(role) }
}

# For avec String directive
variable "names" {
  description = "Names to render"
  type        = list(string)
  default     = ["neo", "trinity", "morpheus"]
}

output "for_directive" {
  value = "%{for name in var.names}${name}, %{endfor}"
}

output "for_directive_index" {
  value = "%{for i, name in var.names}${i} ${name},%{endfor}"
}
