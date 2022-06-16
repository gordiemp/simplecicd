resource "aws_vpc" "nginx-web-server" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "Nginx WebServer VPC"
  }
}

#IG for our subnets

resource "aws_internet_gateway" "nginx-web-server" {
  vpc_id = aws_vpc.nginx-web-server.id
}


#RT

resource "aws_route_table" "allow-outgoing-access" {
  vpc_id = aws_vpc.nginx-web-server.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nginx-web-server.id
  }

  tags = {
    Name = "Route Table Allowing Outgoing Access"
  }
}

resource "aws_subnet" "subnet-public-nginx" {
  cidr_block        = "10.0.3.0/24"
  vpc_id            = aws_vpc.nginx-web-server.id
  availability_zone = "us-east-1a"

  tags = {
    Name = "Nginx Subnet"
  }
}

resource "aws_route_table_association" "nginx-web-server" {
  subnet_id      = aws_subnet.subnet-public-nginx.id
  route_table_id = aws_route_table.allow-outgoing-access.id
}

#SG http

resource "aws_security_group" "allow-web-traffic" {
  name        = "allow-web-traffic"
  description = "Allow HTTP / HTTPS inbound traffic"
  vpc_id      = aws_vpc.nginx-web-server.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#SG ssh

resource "aws_security_group" "allow-ssh-traffic" {
  name        = "allow-ssh-traffic"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.nginx-web-server.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#SG allow outbound

resource "aws_security_group" "allow-all-outbound" {
  name        = "allow-all-outbound"
  description = "Allow all outbound traffic"
  vpc_id      = aws_vpc.nginx-web-server.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}