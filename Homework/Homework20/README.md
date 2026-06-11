# Homework 20: AWS Terraform Module Exercise

У цій домашній роботі було виконано практичну роботу зі створення Terraform-модуля для підняття інфраструктури в AWS.

## Використані AWS-сервіси та інструменти

У роботі були використані такі сервіси та інструменти:

* Terraform
* Terraform Module
* AWS Provider for Terraform
* AWS CLI
* VPC
* Security Groups
* EC2
* Nginx
* S3
* S3 Backend
* Terraform State

## Опис

Під час виконання домашнього завдання було створено Terraform-модуль, який приймає такі вхідні значення:

* `vpc_id`
* `list_of_open_ports`

Модуль створює Security Group у вказаній VPC та відкриває доступ з Інтернету до портів, які передані у змінній `list_of_open_ports`.

Також було створено публічний EC2-інстанс у регіоні `eu-central-1`.

На EC2-інстансі автоматично встановлюється та запускається Nginx.

Після створення інфраструктури Terraform виводить публічну IP-адресу EC2-інстансу.

Для зберігання Terraform state було налаштовано S3 backend.

## Створені ресурси

За допомогою Terraform було створено:

* Security Group у вказаній VPC
* Inbound rules для портів `22` та `80`
* Outbound rule для всього трафіку
* EC2-інстанс у публічній підмережі
* встановлений та запущений Nginx на EC2
* S3 backend для зберігання Terraform state

## Структура проєкту

```text
Homework20/
├── README.md
├── Src/
│   ├── backend.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── terraform.tfvars
│   ├── variables.tf
│   ├── .terraform.lock.hcl
│   └── modules/
│       └── nginx_ec2/
│           ├── main.tf
│           ├── outputs.tf
│           └── variables.tf
└── Screens/
```

## Terraform-файли

Основний код інфраструктури знаходиться у файлі:

```text
main.tf
```

У файлі `main.tf` підключено Terraform-модуль:

```hcl
module "nginx_ec2" {
  source = "./modules/nginx_ec2"

  vpc_id             = var.vpc_id
  list_of_open_ports = var.list_of_open_ports
}
```

Змінні для проєкту знаходяться у файлі:

```text
variables.tf
```

Значення змінних знаходяться у файлі:

```text
terraform.tfvars
```

Outputs з публічною IP-адресою EC2-інстансу знаходяться у файлі:

```text
outputs.tf
```

Налаштування AWS Provider знаходиться у файлі:

```text
provider.tf
```

Налаштування S3 backend знаходиться у файлі:

```text
backend.tf
```

Код Terraform-модуля знаходиться у папці:

```text
modules/nginx_ec2/
```

## Вхідні змінні

Terraform-модуль приймає такі змінні:

```hcl
variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "list_of_open_ports" {
  description = "List of open ports"
  type        = list(number)
}
```

У роботі були використані такі значення:

```hcl
vpc_id = "vpc-092b8a9a3c8ec43c5"

list_of_open_ports = [22, 80]
```

Порт `22` використовується для SSH-доступу.

Порт `80` використовується для доступу до Nginx через HTTP.

## Security Group

Security Group створюється у VPC, яка передається через змінну `vpc_id`.

Для створення правил доступу використовується список портів зі змінної `list_of_open_ports`.

У модулі використано `dynamic "ingress"`, щоб автоматично створити inbound rules для кожного переданого порту.

```hcl
dynamic "ingress" {
  for_each = var.list_of_open_ports

  content {
    description = "Open port ${ingress.value}"
    from_port   = ingress.value
    to_port     = ingress.value
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

У результаті Security Group дозволяє доступ з Інтернету до портів `22` та `80`.

## EC2 та Nginx

EC2-інстанс було створено у регіоні:

```text
eu-central-1
```

Інстанс має назву:

```text
homework20-nginx-ec2
```

Для встановлення Nginx використано `user_data`.

```bash
#!/bin/bash
dnf update -y
dnf install nginx -y
systemctl enable nginx
systemctl start nginx
echo "<h1>Hello from Homework20 Terraform Nginx</h1>" > /usr/share/nginx/html/index.html
```

Після створення EC2-інстансу Terraform вивів публічну IP-адресу:

```text
3.68.108.32
```

## Backend

Для зберігання Terraform state було налаштовано S3 backend.

Оскільки назва S3 bucket повинна бути унікальною глобально в AWS, було використано унікальну назву bucket:

```text
terraform-state-danit-devops-di0geen-352312075095
```

State-файл зберігається за шляхом:

```text
Di0Geen/homework20/terraform.tfstate
```

Backend налаштовано у файлі `backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket = "terraform-state-danit-devops-di0geen-352312075095"
    key    = "Di0Geen/homework20/terraform.tfstate"
    region = "eu-central-1"
  }
}
```

Після створення інфраструктури файл `terraform.tfstate` був створений у S3 bucket.

## Виконані Terraform-команди

Для форматування коду було виконано:

```bash
terraform fmt -recursive
```

Для ініціалізації Terraform та підключення S3 backend було виконано:

```bash
terraform init
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

Результат виконання:

```text
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

## Output

Після створення інфраструктури Terraform вивів публічну IP-адресу EC2-інстансу:

```text
instance_public_ip = "3.68.108.32"
```

## Перевірка роботи Nginx

Після створення інфраструктури було відкрито публічну IP-адресу EC2-інстансу у браузері:

```text
http://3.68.108.32
```

У браузері відобразилась сторінка:

```text
Hello from Homework20 Terraform Nginx
```

Це підтверджує, що EC2-інстанс було створено успішно, Nginx встановлено та HTTP-доступ працює.

## Перевірка Terraform state у S3

Після створення інфраструктури було перевірено, що Terraform state-файл створився у S3 bucket.

Bucket:

```text
terraform-state-danit-devops-di0geen-352312075095
```

Шлях до state-файлу:

```text
Di0Geen/homework20/terraform.tfstate
```

У S3 Console видно файл:

```text
terraform.tfstate
```

## Видалення інфраструктури

Після завершення перевірки створені ресурси можна видалити за допомогою команди:

```bash
terraform destroy
```

Після підтвердження Terraform видалить EC2-інстанс та Security Group, які були створені для цього домашнього завдання.

## Висновок

У результаті виконання домашнього завдання було створено Terraform-модуль для підняття AWS-інфраструктури.

Модуль приймає `vpc_id` та `list_of_open_ports`.

Було створено Security Group з відкритими портами `22` та `80`.

Також було створено публічний EC2-інстанс із встановленим Nginx.

Після створення інфраструктури Terraform вивів публічну IP-адресу EC2-інстансу.

Роботу Nginx було перевірено через браузер.

Terraform state було збережено у S3 bucket за унікальним шляхом.
