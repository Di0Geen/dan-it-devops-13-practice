# Homework 21: AWS Terraform and Ansible

У цій домашній роботі було виконано практичну роботу зі створення AWS-інфраструктури за допомогою Terraform та налаштування EC2-екземплярів за допомогою Ansible.

## Використані AWS-сервіси та інструменти

У роботі були використані такі сервіси та інструменти:

* Terraform
* AWS Provider for Terraform
* Local Provider for Terraform
* AWS CLI
* EC2
* Security Groups
* SSH Key Pair
* Ansible
* Docker
* Docker Compose
* Nginx

## Опис

Terraform-код створює два EC2-екземпляри Ubuntu в AWS, Security Group з відкритими портами `22` та `80`, AWS Key Pair для SSH-доступу та автоматично генерує Ansible inventory файл.

Після створення інфраструктури вручну запускається Ansible playbook. Він встановлює Docker, Docker Compose plugin, завантажує Docker-образ Nginx та запускає Nginx через Docker Compose на обох EC2-екземплярах.

## Створені ресурси

За допомогою Terraform було створено:

* 2 EC2-екземпляри;
* Security Group;
* inbound rule для SSH на порт `22`;
* inbound rule для HTTP на порт `80`;
* outbound rule для всього трафіку;
* AWS Key Pair;
* Ansible inventory файл.

## Структура проєкту

```text
Homework21/
├── README.md
├── Screens/
└── Src/
    ├── ansible/
    │   ├── ansible.cfg
    │   ├── inventory.example.ini
    │   └── playbook.yml
    └── terraform/
        ├── main.tf
        ├── outputs.tf
        ├── terraform.tfvars
        ├── variables.tf
        └── versions.tf
```

Файл `inventory.ini` створюється автоматично після виконання `terraform apply`.

Після виконання `terraform destroy` файл `inventory.ini` видаляється, тому що він керується Terraform через ресурс `local_file`.

У репозиторії залишено приклад inventory:

```text
Src/ansible/inventory.example.ini
```

## Terraform

Основний код інфраструктури знаходиться у файлі:

```text
Src/terraform/main.tf
```

У Terraform створюються:

* AWS Key Pair;
* Security Group;
* два EC2-екземпляри;
* Ansible inventory файл.

Для створення двох EC2 використовується ресурс:

```hcl
resource "aws_instance" "web" {
  count = var.instance_count

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = element(data.aws_subnets.default.ids, count.index)
  vpc_security_group_ids      = [aws_security_group.homework21.id]
  key_name                    = aws_key_pair.homework21.key_name
  associate_public_ip_address = true

  tags = {
    Name     = "homework21-ec2-${count.index + 1}"
    Homework = "21"
  }
}
```

Ansible inventory створюється автоматично за допомогою:

```hcl
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.ini"

  content = <<-EOF
[web]
%{ for instance in aws_instance.web ~}
${instance.tags.Name} ansible_host=${instance.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${pathexpand(var.private_key_path)}
%{ endfor ~}

[web:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF

  depends_on = [aws_instance.web]
}
```

Змінні знаходяться у файлі:

```text
Src/terraform/variables.tf
```

Значення змінних знаходяться у файлі:

```text
Src/terraform/terraform.tfvars
```

Outputs знаходяться у файлі:

```text
Src/terraform/outputs.tf
```

## Основні змінні

У роботі були використані такі значення:

```hcl
aws_region       = "eu-central-1"
instance_type    = "t2.micro"
instance_count   = 2
public_key_path  = "~/.ssh/homework21.pub"
private_key_path = "~/.ssh/homework21"
```

## Security Group

Security Group відкриває:

* порт `22` для SSH;
* порт `80` для HTTP-доступу до Nginx.

```hcl
ingress {
  description = "Allow SSH"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

ingress {
  description = "Allow HTTP"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
```

## EC2

Terraform створив два EC2-екземпляри Ubuntu у регіоні:

```text
eu-central-1
```

Назви EC2-екземплярів:

```text
homework21-ec2-1
homework21-ec2-2
```

Після створення інфраструктури Terraform вивів публічні IP-адреси:

```text
3.68.30.108
18.194.185.124
```

## Ansible inventory

Terraform автоматично створив inventory файл:

```text
Src/ansible/inventory.ini
```

Згенерований inventory мав такий вигляд:

```ini
[web]
homework21-ec2-1 ansible_host=3.68.30.108 ansible_user=ubuntu ansible_ssh_private_key_file=/Users/arhont/.ssh/homework21
homework21-ec2-2 ansible_host=18.194.185.124 ansible_user=ubuntu ansible_ssh_private_key_file=/Users/arhont/.ssh/homework21

[web:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

Після `terraform destroy` цей файл було автоматично видалено.

## Ansible playbook

Код Ansible playbook знаходиться у файлі:

```text
Src/ansible/playbook.yml
```

Playbook виконує такі дії:

* встановлює Docker;
* встановлює Docker Compose plugin;
* створює директорію для застосунку;
* створює `docker-compose.yml`;
* завантажує образ `nginx:latest`;
* запускає Nginx через Docker Compose;
* перевіряє запущені Docker-контейнери.

Основна частина Docker Compose:

```yaml
services:
  nginx:
    image: nginx:latest
    container_name: homework21-nginx
    restart: always
    ports:
      - "80:80"
```

## Виконані Terraform-команди

Усі Terraform-команди виконувалися з папки:

```text
Src/terraform/
```

Було виконано:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Результат створення інфраструктури:

```text
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
```

Terraform output:

```text
ec2_public_ips = [
  "3.68.30.108",
  "18.194.185.124",
]

nginx_urls = [
  "http://3.68.30.108",
  "http://18.194.185.124",
]
```

## Виконані Ansible-команди

Усі Ansible-команди виконувалися з папки:

```text
Src/ansible/
```

Перевірка підключення:

```bash
ansible all -m ping
```

Результат:

```text
homework21-ec2-2 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}

homework21-ec2-1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

Запуск playbook:

```bash
ansible-playbook playbook.yml
```

Результат виконання:

```text
PLAY RECAP
homework21-ec2-1 : ok=15 changed=8 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
homework21-ec2-2 : ok=15 changed=8 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

У результаті було запущено контейнер:

```text
nginx:latest
0.0.0.0:80->80/tcp
homework21-nginx
```

## Перевірка роботи Nginx

Після виконання Ansible playbook було відкрито обидві адреси у браузері:

```text
http://3.68.30.108
http://18.194.185.124
```

У браузері відобразилась сторінка:

```text
Welcome to nginx!
```

Це підтверджує, що Nginx був успішно запущений на обох EC2-екземплярах.

## Видалення інфраструктури

Після перевірки всі ресурси були видалені командою:

```bash
terraform destroy
```

Terraform показав план видалення:

```text
Plan: 0 to add, 0 to change, 5 to destroy.
```

Результат виконання:

```text
Destroy complete! Resources: 5 destroyed.
```

Було видалено:

* 2 EC2-екземпляри;
* Security Group;
* AWS Key Pair;
* Ansible inventory file.

## Висновок

У результаті виконання домашнього завдання було створено Terraform-код для запуску двох EC2-екземплярів в AWS.

Terraform автоматично створив Ansible inventory файл з IP-адресами EC2.

Після цього Ansible playbook вручну встановив Docker, Docker Compose plugin та запустив Nginx через Docker Compose на обох EC2.

Роботу Nginx було перевірено через браузер.

Після завершення роботи всі створені ресурси були видалені за допомогою `terraform destroy`.
