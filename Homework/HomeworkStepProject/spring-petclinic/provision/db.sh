#!/bin/bash
set -euo pipefail

DB_USER="${DB_USER:-petuser}"
DB_PASS="${DB_PASS:-petpass123}"
DB_NAME="${DB_NAME:-petclinic}"
DB_BIND_IP="${DB_BIND_IP:-192.168.56.10}"

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y mysql-server

# MySQL слухає ТІЛЬКИ приватний IP
sed -i "s/^\s*bind-address\s*=.*/bind-address = ${DB_BIND_IP}/" /etc/mysql/mysql.conf.d/mysqld.cnf || true
systemctl restart mysql
systemctl enable mysql

# База + юзер тільки з 192.168.56.0/24
mysql -u root <<MYSQL
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'192.168.56.%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'192.168.56.%';
FLUSH PRIVILEGES;
MYSQL

ss -lntp | grep 3306 || true