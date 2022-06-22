resource "aws_secretsmanager_secret" "allowsecret12" {
  name = "allowsecret12"
}

resource "aws_secretsmanager_secret_version" "allowsecret12" {
  secret_id     = aws_secretsmanager_secret.allowsecret12.id
  secret_string = jsonencode(var.secrets)
}