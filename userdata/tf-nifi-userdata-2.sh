#!/bin/bash
# set nodeid
echo 2 > /opt/node_id

# set hostname
hostnamectl set-hostname tf-nifi-2
