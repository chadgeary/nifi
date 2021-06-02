# Reference
NiFi secure+autoscaling cluster built automatically in AWS via Terraform+Ansible.

# Options
Two designs are provided, either:
- NiFi on EC2 with Zookeeper running within the same EC2 instances, or
- NiFi on EC2 with Zookeeper running separately in ECS Fargate.
- Side note - for considerations about using RHEL as opposed to Ubuntu as the base EC2 OS, see `rhel.md`.

# Requirements
- An AWS account
- Follow Step-by-Step (compatible with Windows and Ubuntu)

# Media 
- [Video Guide](https://youtu.be/7idB-OuDOd0) - a bit outdated, but still useful. Follow along with me as I deploy using the step-by-step guide below.
- [Discord](https://discord.gg/G6W4UDJEZ3) - for questions, ideas, comments, or troubleshooting assistance.

# Step-by-Step Terraform Deployment 
Windows Users install WSL (Windows Subsystem Linux)
```
#############################
## Windows Subsystem Linux ##
#############################
# Launch an ELEVATED Powershell prompt (right click -> Run as Administrator)

# Enable Windows Subsystem Linux
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# Reboot your Windows PC
shutdown /r /t 5

# After reboot, launch a REGULAR Powershell prompt (left click).
# Do NOT proceed with an ELEVATED Powershell prompt.

# Download the Ubuntu 2004 package from Microsoft
curl.exe -L -o ubuntu-2004.appx https://aka.ms/wsl-ubuntu-2004
 
# Rename the package
Rename-Item ubuntu-2004.appx ubuntu-2004.zip
 
# Expand the zip
Expand-Archive ubuntu-2004.zip ubuntu-2004
 
# Change to the zip directory
cd ubuntu-2004
 
# Execute the ubuntu 2004 installer
.\ubuntu2004.exe
 
# Create a username and password when prompted
```
Install Terraform, Git, and create an SSH key pair
```
#############################
##  Terraform + Git + SSH  ##
#############################
# Add terraform's apt key (enter previously created password at prompt)
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
 
# Add terraform's apt repository
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
 
# Install terraform and git
sudo apt-get update && sudo apt-get -y install terraform git
 
# Clone the project
git clone https://github.com/chadgeary/nifi

# Create SSH key pair (RETURN for defaults)
ssh-keygen
```

Install the AWS cli and create non-root AWS user. An [AWS account](https://portal.aws.amazon.com/billing/signup) is required to continue.
```
#############################
##          AWS            ##
#############################
# Open powershell and start WSL
wsl

# Change to home directory
cd ~

# Install python3 pip
sudo apt update && sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y install python3-pip

# Install awscli via pip
pip3 install --user --upgrade awscli

# Create a non-root AWS user in the AWS web console with admin permissions
# This user must be the same user running terraform apply
# Create the user at the AWS Web Console under IAM -> Users -> Add user -> Check programmatic access and AWS Management console -> Attach existing policies -> AdministratorAccess -> copy Access key ID and Secret Access key
# See for more information: https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html#getting-started_create-admin-group-console

# Set admin user credentials
~/.local/bin/aws configure

# Validate configuration
~/.local/bin/aws sts get-caller-identity 

# For troubleshooting EC2 instances, use the SSM Session Manager plugin
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o ~/session-manager-plugin.deb
sudo dpkg -i ~/session-manager-plugin.deb

# and set the SSH helper configuration for SSM Session Manager
tee -a ~/.ssh/config << EOM
host i-* mi-*
    ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
EOM
```

Customize the deployment - See variables section below
```
# Change to the project's aws directory in powershell
cd ~/nifi/ubuntu/

# Open File Explorer in a separate window
# Navigate to ubuntu project directory - change \chad\ to your WSL username
%HOMEPATH%\ubuntu-2004\rootfs\home\chad\nifi\ubuntu

# Edit the nifi.tfvars file using notepad and save
```

Deploy
```
# In powershell's WSL window, change to the project's aws directory
cd ~/nifi/ubuntu/

# Initialize terraform and apply the terraform state
terraform init
terraform apply -var-file="nifi.tfvars"

# If permissions errors appear, fix with the below command and re-run the terraform apply.
sudo chown $USER nifi.tfvars && chmod 600 nifi.tfvars

# Note the outputs from terraform after the apply completes

# Wait for the virtual machine to become ready (Ansible will setup the services for us). NiFi can take 15+ minutes to initialize.
```

# Variables
```
# instance_key
# a public SSH key for SSH access to the instance via user `ubuntu`, service port 22 must be exposed.
# cat ~/.ssh/id_rsa.pub

# mgmt_cidrs
# IP ranges granted web_port access.

# client_cidrs
# IP ranges granted service port(s) access.

# kms_manager
# The AWS username (not root) granted access to read configuration files in S3.

# name_prefix
# a short alphanumeric* string *(must starting with a letter) applied to various AWS resource names.
```

# Post-Deployment
Review terraform output for quick links to State Manager (ansible) status, Load Balancer health, Cloudwatch logs, and the admin certificate in S3 which must be added to a browser for web access.

# Maintenance
If modifying nifi.properties:
1. Change the nifi.properties file in `playbooks/zookeepers/` and `playbooks/nodes/`
2. Re-run `terraform apply -var-file="nifi.tfvars"`
3. Re-apply the SSM associations mentioned in `terraform output`

If re-sizing instances or otherwise modifying autoscaling group(s):
1. Change the instance type in `nifi.tfvars`
2. Re-run `terraform apply -var-file="nifi.tfvars"`
3. Scale the node autoscaling group down, either all at once (min 0 / max 0) or incrementally to replace instances of the old size/AMI.
4. Scale the zookeeper autoscaling groups down, always leave at least one zookeeper running, preferably two - e.g.:
  - If zk1, zk2, and zk3 are running, scale down zk3. Once complete, scale zk3 back up.
  - Repeat for zk2, then zk3.
