#!/bin/bash

# Installation script for SonarQube and Sentry
# This script will use Ansible to deploy to 10.20.1.2 with user user1

set -e

echo "=========================================="
echo "SonarQube & Sentry Installation Script"
echo "=========================================="
echo ""

# Check if Ansible is installed
if ! command -v ansible &> /dev/null; then
    echo "Ansible is not installed. Installing..."
    pip3 install -r requirements.txt
else
    echo "Ansible is already installed."
fi

# Check if SSH key exists
if [ ! -f ~/.ssh/id_rsa ]; then
    echo ""
    echo "WARNING: SSH key not found at ~/.ssh/id_rsa"
    echo "Please ensure you have:"
    echo "1. Generated an SSH key pair (ssh-keygen)"
    echo "2. Copied the public key to the target server (ssh-copy-id user1@10.20.1.2)"
    echo ""
    read -p "Do you want to continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check SSH connectivity
echo ""
echo "Testing SSH connectivity to 10.20.1.2..."
if ssh -o ConnectTimeout=5 -o BatchMode=yes user1@10.20.1.2 exit 2>/dev/null; then
    echo "SSH connection successful!"
else
    echo "WARNING: Cannot connect to 10.20.1.2 via SSH"
    echo "Please ensure:"
    echo "1. The target server is accessible"
    echo "2. SSH keys are properly configured"
    echo "3. User 'user1' exists on the target server"
    echo ""
    read -p "Do you want to continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Run the Ansible playbook
echo ""
echo "Starting installation..."
echo ""
ansible-playbook -i inventory.yml playbook.yml

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "SonarQube: http://10.20.1.2:9000"
echo "  Default credentials: admin/admin"
echo ""
echo "Sentry: http://10.20.1.2:9001"
echo "  Check logs for initial credentials:"
echo "  cd /opt/sentry && docker-compose logs web | grep -i admin"
echo ""
echo "IMPORTANT: Change all default passwords!"
echo "=========================================="
