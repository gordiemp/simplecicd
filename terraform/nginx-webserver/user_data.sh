#! /bin/bash
sudo yum update -y

#install webserver
sudo yum install nginx
sudo systemctl start nginx.service
sudo systemctl status nginx.service