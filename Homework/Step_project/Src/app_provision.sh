#!/bin/bash

sudo apt update
sudo apt install openjdk-17-jdk git -y

sudo useradd -m app_user

sudo -u app_user git clone https://github.com/spring-projects/spring-petclinic.git /home/app_user/project

cd /home/app_user/project

sudo -u app_user ./mvnw test
sudo -u app_user ./mvnw package

cp target/*.jar /home/app_user/

echo "export DB_HOST=192.168.64.10" >> /home/app_user/.bashrc
echo "export DB_PORT=3306" >> /home/app_user/.bashrc
echo "export DB_NAME=${DB_NAME}" >> /home/app_user/.bashrc
echo "export DB_USER=${DB_USER}" >> /home/app_user/.bashrc
echo "export DB_PASS=${DB_PASS}" >> /home/app_user/.bashrc

sudo -u app_user bash -c "cd /home/app_user && java -jar *.jar &"