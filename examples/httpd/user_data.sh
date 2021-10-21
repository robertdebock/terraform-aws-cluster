#!/bin/bash

# Update packages by default.
yum -y update

# Run a webserver.
yum -y install httpd
service httpd start
chkconfig httpd on
