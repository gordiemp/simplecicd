resource "aws_secretsmanager_secret" "jenkins" {
  name = "mavenssecret1"
}

resource "aws_secretsmanager_secret_version" "jenkins" {
  secret_id     = aws_secretsmanager_secret.jenkins.id
  secret_string = jsonencode(var.secrets)
}