resource "aws_secretsmanager_secret" "allowsecret1" {
  name = "allowsecret1"
}

resource "aws_secretsmanager_secret_version" "allowsecret1" {
  secret_id     = aws_secretsmanager_secret.allowsecret1.id
  secret_string = jsonencode(var.secrets)
}