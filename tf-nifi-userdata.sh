#!/bin/bash
# set hostname
sudo hostnamectl set-hostname tf-nifi-1

# update
sudo yum -y update

# install ssm
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
