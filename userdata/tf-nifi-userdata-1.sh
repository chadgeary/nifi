#!/bin/bash
# set nodeid
echo 1 > /opt/node_id

# set hostname
hostnamectl set-hostname tf-nifi-1
