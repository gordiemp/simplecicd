# Production Repository

resource "aws_ecr_repository" "nginx-webserver" {
  name                 = "nginx-webserver"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "Elastic Container Registry to store Docker Artifacts"
  }
}