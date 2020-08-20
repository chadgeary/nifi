#!/bin/bash
# set JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/default-java

# run toolkit server briefly to generate conf
/opt/nifi-toolkit/bin/tls-toolkit.sh server -a RSA -c tf-nifi-1 -d 3650 -D "CN={{ ansible_hostname }},OU=NIFI" -f /opt/nifi-certificates/nifi-ca/tls.json -k 2048 -p 2170 -s SHA256WITHRSA -T jks -t {{ generated_password.stdout }} &

# capture pid
TOOLKIT_PID=$!

# sleep a moment, then kill the toolkit server instance
sleep 10 && kill $TOOLKIT_PID
