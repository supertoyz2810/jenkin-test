#!/bin/bash

set -eux

sudo apt-get update && sudo apt-get upgrade -y

sudo apt-get install -y fontconfig openjdk-21-jre curl gnupg2 wget

wget -O /etc/apt/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update && sudo apt-get install -y jenkins

sudo systemctl enable jenkins
sudo systemctl start jenkins