# SSH key - Web App

resource "aws_key_pair" "nginx-webserver-key" {
  key_name   = "nginx-webserver"
  public_key = file("./nginx_webserver.pem")
  #public_key = file("./nginx_webserver.pem")
}