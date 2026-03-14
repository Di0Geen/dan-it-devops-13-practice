#!/bin/bash

sudo apt update
sudo apt install mysql-server -y

sudo systemctl enable mysql
sudo systemctl start mysql

sudo sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql

sudo mysql <<EOF
CREATE DATABASE ${DB_NAME};
CREATE USER '${DB_USER}'@'192.168.64.%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'192.168.64.%';
FLUSH PRIVILEGES;
EOF