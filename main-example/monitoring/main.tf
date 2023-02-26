# Ca ne va pas marcher ca. Il faut que les users soient des outputs du module
module "webserver_cluster" {
  source = "../users"
}

resource "aws_iam_user_policy_attachment" "neo_cloudwatch_full_access" {
  count = var.give_neo_cloudwatch_full_access ? 1 : 0

  user       = aws_iam_user.example[0].name
  policy_arn = aws_iam_policy.cloudwatch_full_access.arn
}

resource "aws_iam_user_policy_attachment" "neo_cloudwatch_read_only" {
  count = var.give_neo_cloudwatch_full_access ? 0 : 1

  user       = aws_iam_user.example[0].name
  policy_arn = aws_iam_policy.cloudwatch_read_only.arn
}

# Solution fragile pour retourner la resource créée en fonction de la conditional. Préférer l'utilisation de one et concat plus bas
output "neo_cloudwatch_policy_arn_fragile" {
  value = (
    var.give_neo_cloudwatch_full_access
    ? aws_iam_user_policy_attachment.neo_cloudwatch_full_access[0].policy_arn
    : aws_iam_user_policy_attachment.neo_cloudwatch_read_only[0].policy_arn
  )
}

output "neo_cloudwatch_policy_arn" {
    value = one(concat(
        aws_iam_user_policy_attachment.neo_cloudwatch_full_access[*].policy_arn,
        aws_iam_user_policy_attachment.neo_cloudwatch_read_only[*].policy_arn
    ))
}