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

#Jenkins Subnet

resource "aws_subnet" "subnet-public-jenkins" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.nginx-web-server.id
  availability_zone = "us-east-1a"

  tags = {
    Name = "Jenkins Subnet"
  }
}

#Nginx Subnet

resource "aws_subnet" "subnet-public-nginx" {
  cidr_block        = "10.0.3.0/24"
  vpc_id            = aws_vpc.nginx-web-server.id
  availability_zone = "us-east-1a"

  tags = {
    Name = "Nginx Subnet"
  }
}

#Route table Jenkins

resource "aws_route_table_association" "jenkins-subnet" {
  subnet_id = aws_subnet.subnet-public-jenkins.id
  route_table_id = aws_route_table.allow-outgoing-access.id  
}


#Route table Nginx

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


# 6.3 Create a Security Group for inbound traffic to Jenkins

resource "aws_security_group" "allow-jenkins-traffic" {
  name = "allow-jenkins-traffic"
  description = "Allow jenkins inbound traffic"
  vpc_id = aws_vpc.nginx-web-server.id

  ingress {
    description = "Jenkins"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#SG outbound traffic

resource "aws_security_group" "allow-all-outbound" {
  name        = "allow-all-outbound"
  description = "Allow all outbound traffic"
  vpc_id      = aws_vpc.nginx-web-server.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Outbound traffic"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }
}

resource "aws_network_interface" "jenkins" {
  subnet_id = aws_subnet.subnet-public-jenkins.id
  private_ips = ["10.0.1.50"]
  security_groups = [ aws_security_group.allow-all-outbound.id,
                      aws_security_group.allow-ssh-traffic.id,
                      aws_security_group.allow-jenkins-traffic.id]  
}

resource "aws_network_interface" "nginx-web-server" {
  subnet_id = aws_subnet.subnet-public-nginx.id
  private_ips = ["10.0.3.50"]
  security_groups = [ aws_security_group.allow-all-outbound.id,
                      aws_security_group.allow-ssh-traffic.id,
                      aws_security_group.allow-web-traffic.id]
}

# 8.1 Assign an Elastic IP to the Network Interface of Jenkins

resource "aws_eip" "jenkins" {
  vpc = true
  network_interface = aws_network_interface.jenkins.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [
    aws_internet_gateway.nginx-web-server
  ]
}

# 8.2 Assign an Elastic IP to the Network Interface of Simple Web App

resource "aws_eip" "simple-web-app" {
  vpc = true
  network_interface = aws_network_interface.nginx-web-server.id
  associate_with_private_ip = "10.0.3.50"
  depends_on = [
    aws_internet_gateway.nginx-web-server
  ]
}

