#!/bin/bash
# set JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/jre

# ensure cert dir
mkdir -p /mnt/tf-nifi-efs/nifi-certificates/{{ ansible_nodename }}

# run toolkit client to generate certificates
grep --quiet "REPLACEDBYTOOLKIT" /opt/nifi/conf/nifi.properties
if [ $? -eq 0 ]
then
  /opt/nifi-toolkit/bin/tls-toolkit.sh client -a RSA -c tf-nifi-1 -p 2170 -D "CN={{ ansible_nodename }},OU=NIFI" --subjectAlternativeNames {{ ansible_nodename }} -f /mnt/tf-nifi-efs/nifi-certificates/{{ ansible_nodename }}/tls.json -k 2048 -T jks -t {{ generated_password.stdout }}
fi

# replace password in properties
KEYSTORE_PASSWORD=$(awk -F'"' '/keyStorePassword/ { print $4 }' /mnt/tf-nifi-efs/nifi-certificates/{{ ansible_nodename }}/tls.json)
TRUSTSTORE_PASSWORD=$(awk -F'"' '/trustStorePassword/ { print $4 }' /mnt/tf-nifi-efs/nifi-certificates/{{ ansible_nodename }}/tls.json)

# set in nifi.properties
sed -i -e "s#^nifi.security.keystorePasswd.*#nifi.security.keystorePasswd=$KEYSTORE_PASSWORD#" /opt/nifi/conf/nifi.properties
sed -i -e "s#^nifi.security.keyPasswd.*#nifi.security.keyPasswd=$KEYSTORE_PASSWORD#" /opt/nifi/conf/nifi.properties
sed -i -e "s#^nifi.security.truststorePasswd.*#nifi.security.truststorePasswd=$TRUSTSTORE_PASSWORD#" /opt/nifi/conf/nifi.properties
