#!/bin/bash
set -e

mkdir -p /home/ubuntu/.ssh
echo "${public_key}" >> /home/ubuntu/.ssh/authorized_keys
chown -R ubuntu:ubuntu /home/ubuntu/.ssh
chmod 700 /home/ubuntu/.ssh
chmod 600 /home/ubuntu/.ssh/authorized_keys

apt-get update -y
apt-get install -y openjdk-21-jre docker.io git curl

systemctl enable docker
systemctl start docker

usermod -aG docker ubuntu

mkdir -p /home/ubuntu/jenkins-agent
chown -R ubuntu:ubuntu /home/ubuntu/jenkins-agent