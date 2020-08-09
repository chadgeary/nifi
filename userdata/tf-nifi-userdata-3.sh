#!/bin/bash
# set nodeid
echo 3 > /opt/node_id

# set hostname
hostnamectl set-hostname tf-nifi-3
