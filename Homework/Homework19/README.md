# Homework 19: AWS Terraform VPC Practice

У цій домашній роботі було виконано практичну роботу зі створення власної мережевої інфраструктури в AWS за допомогою Terraform.

## Використані AWS-сервіси та інструменти

У роботі були використані такі сервіси та інструменти:

* Terraform
* AWS Provider for Terraform
* VPC
* Public Subnet
* Private Subnet
* Internet Gateway
* NAT Gateway
* Elastic IP
* Route Tables
* Security Groups
* EC2
* SSH
* AWS CLI

## Опис

Під час виконання домашнього завдання було створено власну VPC та дві підмережі:

* публічну підмережу для EC2-інстансу з доступом з Інтернету;
* приватну підмережу для EC2-інстансу без публічної IP-адреси.

Публічний EC2-інстанс використовувався як bastion host для підключення до приватного EC2-інстансу.

Приватний EC2-інстанс мав вихід в Інтернет через NAT Gateway, що дозволило виконати перевірку за допомогою `ping google.com`.

Після перевірки всі створені ресурси були видалені за допомогою Terraform.

## Створені ресурси

За допомогою Terraform було створено:

* VPC з CIDR-блоком `10.0.0.0/16`
* Public Subnet з CIDR-блоком `10.0.1.0/24`
* Private Subnet з CIDR-блоком `10.0.2.0/24`
* Internet Gateway для доступу публічної підмережі до Інтернету
* Elastic IP для NAT Gateway
* NAT Gateway для доступу приватної підмережі до Інтернету
* Public Route Table
* Private Route Table
* асоціації Route Tables з відповідними підмережами
* Security Group для Public EC2
* Security Group для Private EC2
* EC2-інстанс у публічній підмережі
* EC2-інстанс у приватній підмережі
* AWS Key Pair для SSH-доступу

## Структура проєкту

```text
Homework19/
├── README.md
├── Src/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── .terraform.lock.hcl
└── Screens/
```

## Terraform-файли

Основний код інфраструктури знаходиться у файлі:

```text
main.tf
```

У файлі `main.tf` описано створення:

* AWS Provider
* VPC
* Public Subnet
* Private Subnet
* Internet Gateway
* NAT Gateway
* Route Tables
* Security Groups
* Public EC2
* Private EC2

Змінні для проєкту знаходяться у файлі:

```text
variables.tf
```

Outputs з IP-адресами та SSH-командами знаходяться у файлі:

```text
outputs.tf
```

## Виконані Terraform-команди

Для ініціалізації Terraform було виконано:

```bash
terraform init
```

Для форматування коду було виконано:

```bash
terraform fmt
```

Для перевірки конфігурації було виконано:

```bash
terraform validate
```

Для перегляду плану створення ресурсів було виконано:

```bash
terraform plan
```

Для створення інфраструктури було виконано:

```bash
terraform apply
```

Після підтвердження команда створила необхідні AWS-ресурси.

## Перевірка підключення до Public EC2

Після створення інфраструктури було виконано підключення з локального комп'ютера до EC2-інстансу у публічній підмережі:

```bash
ssh -A -i ~/.ssh/terraform-homework-key ec2-user@52.57.169.61
```

Публічний EC2-інстанс мав приватну IP-адресу:

```text
10.0.1.140
```

## Перевірка підключення до Private EC2

Після підключення до Public EC2 було виконано SSH-підключення до EC2-інстансу у приватній підмережі:

```bash
ssh ec2-user@10.0.2.157
```

Приватний EC2-інстанс мав IP-адресу:

```text
10.0.2.157
```

Private EC2 не мав публічної IPv4-адреси, тому пряме підключення з Інтернету до нього було недоступне.

## Перевірка доступу до Інтернету з Private EC2

Для перевірки доступу до Інтернету з приватного EC2-інстансу було виконано команду:

```bash
ping -c 4 google.com
```

Результат перевірки показав, що приватний EC2-інстанс має доступ до Інтернету через NAT Gateway:

```text
4 packets transmitted, 4 received, 0% packet loss
```

## Видалення інфраструктури

Після завершення перевірки всі створені ресурси були видалені за допомогою команди:

```bash
terraform destroy -auto-approve
```

Після видалення в AWS Console залишилася тільки стандартна default VPC, а створена Terraform VPC була видалена.

## Формат здачі

До домашнього завдання додано скріни:

1. Код створення VPC, EC2, Gateway, Route Tables та інших ресурсів.
2. Resource Map у VPC з Public Subnet, Private Subnet, Internet Gateway, NAT Gateway та Route Tables.
3. Підключення по SSH до EC2 у публічній підмережі.
4. Підключення по SSH з Public EC2 до Private EC2.
5. Ping `google.com` з EC2 у приватній підмережі.
6. Видалення створеної інфраструктури через Terraform та перевірка в AWS Console.

## Висновок

У результаті виконання домашнього завдання було створено власну VPC за допомогою Terraform.

Було налаштовано публічну та приватну підмережі, Internet Gateway, NAT Gateway, Route Tables, Security Groups та два EC2-інстанси.

Публічний EC2-інстанс був доступний через SSH з локального комп'ютера.

Приватний EC2-інстанс був доступний тільки через Public EC2 та мав вихід в Інтернет через NAT Gateway.

Після перевірки всі створені AWS-ресурси були успішно видалені.
