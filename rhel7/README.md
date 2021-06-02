RHEL *can* use the same terraform / ansible configuration as Ubuntu, with a few small differences. Instead of maintaining an entire codebase, here are the relevant differences:

# Terraform
- To create a KMS-encrypted AMI, launch an instance from the RHEL AMI then make an AMI from the instance.
- Install SSM via userdata, e.g. `yum install -y https://s3.${var.aws_region}.amazonaws.com/amazon-ssm-${var.aws_region}/latest/linux_amd64/amazon-ssm-agent.rpm`
- Install cloudwatch via Ansible via:
```
    - name: cloudwatch user
      user:
        name: cloudwatch
        comment: AWS Cloudwatch Agent Service Account
        groups: adm,nifi
        append: yes

    - name: set messages and secure readable in logrotate syslog
      blockinfile:
        block: |
          #     cloudwatch to read logs
                /bin/setfacl -m g:cloudwatch:rx /var/log/messages
                /bin/setfacl -m g:cloudwatch:rx /var/log/secure
        insertbefore: "    endscript"
        path: /etc/logrotate.d/syslog

    - name: set active messages and secure readable
      acl:
        path: "/var/log/{{ item }}"
        entity: cloudwatch
        etype: group
        permissions: rx
        state: present
      with_items:
        - messages
        - secure

    - name: cloudwatch agent install
      yum:
        name: 'https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm'
        state: latest

    - name: cloudwatch conf
      file:
        path: /opt/aws/amazon-cloudwatch-agent/etc
        state: directory
        mode: 0755
        owner: cloudwatch
        group: cloudwatch

    - name: cloudwatch conf file
      template:
        src: amazon-cloudwatch-agent.json
        dest: /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
        owner: cloudwatch
        group: cloudwatch
        mode: '0440'

    - name: cloudwatch agent load configuration file
      shell: |
          /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
```
- Packages are a bit different too:
```
    - name: nifi required packages
      package:
        name: "{{ packages }}"
        state: latest
      vars:
        packages:
        - java-11-openjdk
        - jq
        - python-pip
        - unzip
      retries: 60
      delay: 3
      register: install_packages
      until: install_packages is not failed

    - name: ansible required packages
      pip:
        executable: /usr/bin/pip
        name: "{{ packages }}"
      vars:
        packages:
        - boto
        - boto3
        - botocore
```
- finally, the Java Runtime Environment is located elsewhere, e.g.: `export JAVA_HOME=/etc/alternatives/jre`
