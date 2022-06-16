module "application-server" {
  source = "./nginx-webserver"

  ami-id = "ami-0742b4e673072066f" # AMI for an Amazon Linux instance for region: us-east-1

  iam-instance-profile = aws_iam_instance_profile.nginx-web-server.name
  key-pair             = aws_key_pair.nginx-webserver-key.key_name
  name                 = "Nginx Webserver"
  repository-url       = "repo URL"
}