# SSH key - Nginx

resource "aws_key_pair" "nginx-webserver-key" {
  key_name   = "nginx-webserver"
  public_key = file("./nginx_webserver.pem")
}

# SSH key - Jenkins

resource "aws_key_pair" "jenkins-key" {
  key_name   = "jenkins"
  public_key = file("./jenkins.pem")
}