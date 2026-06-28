#!/bin/bash
set -e

mkdir -p /home/ubuntu/.ssh
echo "${public_key}" >> /home/ubuntu/.ssh/authorized_keys
chown -R ubuntu:ubuntu /home/ubuntu/.ssh
chmod 700 /home/ubuntu/.ssh
chmod 600 /home/ubuntu/.ssh/authorized_keys

apt-get update -y
apt-get install -y python3