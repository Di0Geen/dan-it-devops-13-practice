# Homework 18: AWS RDS and Lambda Practice

У цій домашній роботі було виконано практичну роботу з AWS RDS та автоматизації зупинки EC2-інстансів за допомогою AWS Lambda.

## Використані AWS-сервіси

У роботі були використані такі сервіси AWS:

- EC2
- RDS
- MySQL
- Lambda
- EventBridge
- IAM
- Security Groups
- Tags
- CloudWatch Logs
- boto3

## Опис

Під час виконання домашнього завдання було створено та налаштовано:

- AWS RDS MySQL database
- Security Group для доступу до RDS
- EC2-інстанс з відповідним тегом
- IAM Role для Lambda Function
- IAM Policy з правами для опису та зупинки EC2-інстансів
- Lambda Function на Python з використанням бібліотеки `boto3`
- EventBridge scheduled rule для запуску Lambda Function за cron-розкладом
- тестовий запуск Lambda Function
- перевірку зупинки EC2-інстансу за тегом
- видалення створених AWS-ресурсів після перевірки

## Завдання 2: AWS RDS MySQL

У межах другого завдання було створено базу даних AWS RDS MySQL.

Було виконано:

- створення RDS MySQL database
- налаштування параметрів бази даних
- перевірку створеної бази даних в AWS Console
- видалення RDS database після завершення перевірки

## Завдання 3: AWS Lambda

У межах третього завдання було створено Lambda Function, яка запускається за розкладом через EventBridge та зупиняє EC2-інстанси з відповідним тегом.

Було виконано:

- створення EC2-інстансу з тегом `Name=Homework18`
- створення IAM Role для Lambda
- додавання прав для роботи з EC2
- створення Lambda Function `StopEC2ByTagHomework18`
- написання Python-коду з використанням `boto3`
- створення EventBridge scheduled rule `StopEC2Homework18`
- налаштування cron-розкладу для запуску Lambda
- ручний тестовий запуск Lambda Function
- перевірка, що EC2-інстанс перейшов у стан `Stopped`
- видалення EventBridge rule
- видалення Lambda Function
- видалення IAM Role
- завершення EC2-інстансу

## Lambda Function

Код Lambda Function знаходиться у папці:

```text
Src/