# Homework 17: AWS VPC Practice


У цій домашній роботі було виконано практичну роботу з налаштування мережевої інфраструктури в AWS.

## Використані AWS-сервіси

У роботі були використані такі сервіси AWS:

- VPC
- Subnets
- Route Tables
- Internet Gateway
- NAT Gateway
- Elastic IP
- EC2
- Security Groups
- SSH

## Опис

Під час виконання домашнього завдання було створено:

- VPC з CIDR-блоком `10.0.0.0/16`
- Public Subnet з CIDR-блоком `10.0.1.0/24`
- Private Subnet з CIDR-блоком `10.0.2.0/24`
- Internet Gateway для доступу публічної підмережі до Інтернету
- Public Route Table з маршрутом `0.0.0.0/0` через Internet Gateway
- NAT Gateway у публічній підмережі
- Private Route Table з маршрутом `0.0.0.0/0` через NAT Gateway
- EC2-інстанс у public subnet
- EC2-інстанс у private subnet