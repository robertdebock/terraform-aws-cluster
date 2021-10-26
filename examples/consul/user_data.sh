#!/bin/bash

# Installs and configures Consul on Amazon Linux using the official approach from the manual
# https://www.consul.io/downloads

# Install yum-utils which contains the yum-config-manager to manage repositories
yum install -y yum-utils

# Using yum-config-manager to add the official HashiCorp rpm repository
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo

# Installing Consul
yum install -y consul

# Run consul agent
consul agent -server -server-port=8600
