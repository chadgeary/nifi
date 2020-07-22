# Reference
Installation of an Apache nifi cluster with LDAP and zookeeper.

# Variables
```
# version of nifi and zookeeper to download/extract/install
nifi_version='1.9.2'
zk_version='3.5.5'

# keystore password
keystore_password='somekeystorepassword'
```

# Ports
```
# nifi
443/tcp # web console
2171/tcp # cluster listen
2172/tcp # cluster loadbalance

# zookeeper - increment if running multiple nifi instances on the same host (e.g. docker)
2181/tcp # client
2182/tcp # quorum
2183/tcp # leader election

# outbound
# all of the above, plus
636/tcp # ldaps

# also
# defined incoming log streams, e.g.
514/udp # syslog
```

# Name Resolution
All nodes must resolve eachothers names
