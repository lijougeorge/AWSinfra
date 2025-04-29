#!/bin/bash

set -e
set -o pipefail

sudo yum update -y

if ! sudo systemctl is-active --quiet amazon-ssm-agent; then
    sudo yum install -y amazon-ssm-agent
    sudo systemctl enable amazon-ssm-agent
    sudo systemctl start amazon-ssm-agent
fi

if ! id "admin" &>/dev/null; then
    sudo useradd -m admin
    echo "admin:Atos@123" | sudo chpasswd
    sudo usermod -aG wheel admin
    echo "admin ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/admin
    sudo chmod 440 /etc/sudoers.d/admin
fi

sudo systemctl status amazon-ssm-agent
