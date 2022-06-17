module "nginx-webserver" {
  source = "./nginx-webserver"

  ami-id = "ami-0742b4e673072066f" # AMI for an Amazon Linux instance for region: us-east-1

  iam-instance-profile = aws_iam_instance_profile.nginx-webserver.name
  key-pair             = aws_key_pair.nginx-webserver-key.key_name
  name                 = "Nginx Webserver"
  repository-url       = "repo URL"
  device-index         = 0
  network-interface-id = aws_network_interface.nginx-web-server.id
}