#!/bin/bash

# Variables
REGION="us-east-1"
INSTANCE_TYPE="t2.micro"
AMI_ID="ami-066784287e358dad1"  # Amazon Linux 2 AMI ID for us-east-1
KEY_NAME="my-ec2-key"  # Replace with your desired key pair name
SECURITY_GROUP_NAME="gitlab-runner-sg"
TAG="cicd"

# Create a .pem key file
KEY_FILE="${KEY_NAME}.pem"
if [ -f "$KEY_FILE" ]; then
    echo "Key file $KEY_FILE already exists. Please choose a different name or delete the existing key."
    exit 1
fi

aws ec2 create-key-pair --key-name $KEY_NAME --query 'KeyMaterial' --output text --region $REGION > $KEY_FILE
if [ $? -ne 0 ]; then
    echo "Failed to create key pair. Exiting."
    exit 1
fi

chmod 400 $KEY_FILE
echo "Created key pair and saved to $KEY_FILE"

# Create Security Group
SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name $SECURITY_GROUP_NAME --description "Security group for GitLab Runner" --region $REGION --query 'GroupId' --output text)
echo "Created security group with ID: $SECURITY_GROUP_ID"

# Allow SSH access on port 22
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 22 --cidr 0.0.0.0/0 --region $REGION
echo "Enabled SSH access on port 22"

# Launch EC2 instance
INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type $INSTANCE_TYPE --key-name $KEY_NAME --security-group-ids $SECURITY_GROUP_ID --region $REGION --query 'Instances[0].InstanceId' --output text)
echo "Launching EC2 instance with ID: $INSTANCE_ID"

# Tag the instance
aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value=GitLab-Runner --region $REGION
echo "Tagged EC2 instance with Name=GitLab-Runner"

# Wait for the instance to be in running state
echo "Waiting for the instance to be running..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region $REGION
echo "Instance is running"

# Get the public IP of the instance
INSTANCE_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --region $REGION --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
echo "EC2 Instance Public IP: $INSTANCE_IP"

# Install GitLab Runner on the instance
echo "Installing GitLab Runner on the EC2 instance..."

# Create a script to install GitLab Runner and Git
INSTALL_RUNNER_SCRIPT=$(cat <<'EOF'
#!/bin/bash
# Update and install necessary packages
sudo yum update -y

# Install Git
sudo yum install -y git

# Add GitLab Runner repository
curl -L --output /etc/yum.repos.d/gitlab-runner.repo https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh

# Install GitLab Runner
sudo yum install gitlab-runner -y

# Register the runner (You'll need to replace these values with your GitLab details)
# sudo gitlab-runner register --non-interactive --url "https://gitlab.com/" --registration-token "glrt-HARxg6bzjhzAfZNo91Df" --executor "shell" --description "GitLab Runner" --tag-list "cicd" --run-untagged="true" --locked="false"

# Start the runner
sudo systemctl enable gitlab-runner
sudo systemctl start gitlab-runner

# Confirm Git installation
git --version

echo "GitLab Runner and Git installed and started"
EOF
)

# SSH into the instance and run the install script
ssh -o "StrictHostKeyChecking=no" -i $KEY_FILE ec2-user@$INSTANCE_IP "bash -s" <<EOF
$INSTALL_RUNNER_SCRIPT
EOF

echo "GitLab Runner and Git installation complete!"
