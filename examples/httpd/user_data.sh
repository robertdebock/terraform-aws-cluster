#!/bin/bash

# Update packages by default.
yum -y update

# Run a webserver.
yum -y install httpd
systemctl --now enable httpd

echo "Hello world" > /var/www/html/index.html
