# Step Project 3: AWS Terraform, Ansible and Jenkins Pipeline

У цьому Step Project було виконано практичну роботу зі створення AWS-інфраструктури за допомогою Terraform, налаштування Jenkins master через Ansible, підключення Jenkins worker та запуску CI/CD pipeline.

## Використані AWS-сервіси та інструменти

У роботі були використані такі сервіси та інструменти:

Terraform
AWS Provider for Terraform
AWS CLI
S3
VPC
Public Subnet
Private Subnet
Internet Gateway
NAT Gateway
Route Tables
Security Groups
EC2 On-Demand Instance
EC2 Spot Instance
SSH Key Pair
User Data
Ansible
Jenkins
Nginx
Docker
Docker Compose
Docker Hub
GitHub

## Опис

У межах проєкту було створено AWS-інфраструктуру для Jenkins master та Jenkins worker.

Terraform-код створює S3 bucket для зберігання Terraform state, VPC, публічну та приватну підмережі, Internet Gateway, NAT Gateway, route tables, Security Groups та два EC2-екземпляри.

Jenkins master розгорнутий у публічній підмережі як on-demand EC2 instance. Jenkins worker розгорнутий у приватній підмережі як spot EC2 instance.

Ansible використовується для встановлення Jenkins та Nginx reverse proxy на Jenkins master.

Після цього вручну в Jenkins було додано worker node, налаштовано SSH-підключення до worker та запущено pipeline зі Step Project 2. Pipeline виконувався саме на Jenkins worker, збирав Docker image, запускав тести та пушив image у Docker Hub.

## Створені ресурси

За допомогою Terraform було створено:

S3 bucket для Terraform state;
VPC;
1 public subnet для Jenkins master;
1 private subnet для Jenkins worker;
Internet Gateway;
NAT Gateway;
Elastic IP для NAT Gateway;
Route Table для public subnet;
Route Table для private subnet;
Security Group для Jenkins master;
Security Group для Jenkins worker;
EC2 On-Demand instance для Jenkins master;
EC2 Spot instance для Jenkins worker;
SSH key configuration через Terraform;
Terraform outputs з IP-адресами та URL.

## Структура проєкту

```text
Step_project3/
├── README.md
├── Screens/
└── Src/
    ├── ansible/
    │   ├── ansible.cfg
    │   ├── inventory.ini
    │   ├── install_jenkins_nginx.yml
    │   └── templates/
    │       └── jenkins.conf.j2
    ├── jenkins/
    │   └── Jenkinsfile
    └── terraform/
        ├── bootstrap/
        │   ├── main.tf
        │   ├── outputs.tf
        │   ├── provider.tf
        │   ├── terraform.tfstate
        │   ├── terraform.tfstate.backup
        │   └── variables.tf
        └── infra/
            ├── backend.tf
            ├── main.tf
            ├── outputs.tf
            ├── provider.tf
            ├── user_data_master.sh
            ├── user_data_worker.sh
            └── variables.tf
```

Папка `Src/terraform/bootstrap` використовується для створення S3 bucket, у якому зберігається Terraform state.

Папка `Src/terraform/infra` використовується для створення основної AWS-інфраструктури.

Папка `Src/ansible` містить Ansible playbook для встановлення Jenkins і Nginx reverse proxy.

Папка `Src/jenkins` містить Jenkins pipeline code.

## Terraform bootstrap

Код створення S3 bucket знаходиться у папці:

```text
Src/terraform/bootstrap/
```

S3 bucket використовується для зберігання Terraform state основної інфраструктури.

Приклад ресурсу S3 bucket:

```hcl
resource "aws_s3_bucket" "tf_state" {
  bucket = "${var.bucket_prefix}-${random_id.suffix.hex}"

  tags = {
    Name    = "Step Project 3 Terraform State"
    Project = "Step Project 3"
  }
}
```

У результаті було створено S3 bucket:

```text
di0geen-step-project-3-tfstate-406026ea
```

## Terraform infrastructure

Основний код інфраструктури знаходиться у папці:

```text
Src/terraform/infra/
```

У Terraform створюються:

VPC;
public subnet;
private subnet;
Internet Gateway;
NAT Gateway;
Route Tables;
Security Groups;
Jenkins master EC2;
Jenkins worker EC2 Spot Instance;
outputs для підключення та перевірки.

## Backend Terraform state

Для основної інфраструктури використовується remote backend у S3.

Файл backend знаходиться тут:

```text
Src/terraform/infra/backend.tf
```

Приклад backend configuration:

```hcl
terraform {
  backend "s3" {
    bucket = "di0geen-step-project-3-tfstate-406026ea"
    key    = "step-project-3/terraform.tfstate"
    region = "eu-central-1"
  }
}
```

## VPC і мережа

Terraform створив окрему VPC для Step Project 3.

У VPC було створено:

public subnet для Jenkins master;
private subnet для Jenkins worker;
Internet Gateway для доступу Jenkins master до інтернету;
NAT Gateway для доступу Jenkins worker до інтернету;
Route Table для public subnet;
Route Table для private subnet.

Jenkins master має public IP і доступний через браузер.

Jenkins worker знаходиться у private subnet і не має прямого public access. Доступ до worker виконується через Jenkins master.

## EC2 instances

Terraform створив два EC2-екземпляри Ubuntu:

```text
Jenkins master: on-demand EC2 instance
Jenkins worker: spot EC2 instance
```

Після створення інфраструктури були отримані такі адреси:

```text
Jenkins master public IP: 3.76.217.56
Jenkins master private IP: 10.0.1.242
Jenkins worker private IP: 10.0.2.212
```

Jenkins master доступний у браузері за адресою:

```text
http://3.76.217.56
```

## Security Groups

Для Jenkins master було дозволено:

SSH доступ на порт `22`;
HTTP доступ на порт `80`;
доступ до Jenkins через Nginx reverse proxy.

Для Jenkins worker було дозволено:

SSH доступ тільки з Jenkins master;
вихідний трафік через NAT Gateway.

Приклад ingress rule для SSH:

```hcl
ingress {
  description = "Allow SSH"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
```

Приклад ingress rule для HTTP:

```hcl
ingress {
  description = "Allow HTTP"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
```

## User Data

Для EC2 instances використовувався Terraform user data.

User data на Jenkins master готує сервер до встановлення Jenkins та додає необхідний SSH-ключ.

User data на Jenkins worker додає SSH-ключ для доступу з Jenkins master та готує сервер до підключення як Jenkins agent.

Файли user data знаходяться тут:

```text
Src/terraform/infra/user_data_master.sh
Src/terraform/infra/user_data_worker.sh
```

## Ansible

Ansible-код знаходиться у папці:

```text
Src/ansible/
```

Основний playbook:

```text
Src/ansible/install_jenkins_nginx.yml
```

Playbook виконує такі дії на Jenkins master:

оновлює apt packages;
встановлює Java;
додає Jenkins repository key;
додає Jenkins repository;
встановлює Jenkins;
запускає Jenkins service;
встановлює Nginx;
копіює Nginx reverse proxy config;
перезапускає Nginx;
перевіряє статус Jenkins та Nginx.

## Nginx reverse proxy

Конфіг Nginx знаходиться у файлі:

```text
Src/ansible/templates/jenkins.conf.j2
```

Nginx налаштований як reverse proxy для Jenkins.

Приклад конфігурації:

```nginx
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Після налаштування Jenkins став доступний через HTTP:

```text
http://3.76.217.56
```

без прямого використання порту `8080`.

## Jenkins master

Jenkins master був встановлений на EC2 instance у public subnet.

Після встановлення Jenkins було відкрито у браузері:

```text
http://3.76.217.56
```

Після першого входу було виконано стандартне налаштування Jenkins:

отримано initial admin password;
встановлено рекомендовані Jenkins plugins;
створено адміністративного користувача;
відкрито Jenkins Dashboard.

## Jenkins worker

Jenkins worker був створений як EC2 Spot Instance у private subnet.

Worker не має public IP. Підключення до нього виконується через Jenkins master.

На worker було перевірено SSH-підключення:

```bash
ssh -i ~/.ssh/step_project_3_key ubuntu@10.0.2.212
```

На worker було встановлено та перевірено:

OpenJDK 21;
Docker;
Docker Compose plugin;
доступ користувача `ubuntu` до Docker без `sudo`.

Перевірка Java:

```bash
java -version
```

Результат:

```text
openjdk version "21.0.11" 2026-04-21
OpenJDK Runtime Environment (build 21.0.11+10-1~24.04.2-Ubuntu)
OpenJDK 64-Bit Server VM (build 21.0.11+10-1~24.04.2-Ubuntu, mixed mode, sharing)
```

Перевірка Docker:

```bash
docker --version
docker compose version
docker ps
```

Результат:

```text
Docker version 29.1.3
Docker Compose version 2.40.3
```

Також було виконано тестовий запуск Docker container:

```bash
docker run hello-world
```

Результат:

```text
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

## Додавання Jenkins worker до Jenkins master

Jenkins worker було додано вручну через Jenkins UI.

Основні налаштування worker node:

```text
Node name: worker
Remote root directory: /home/ubuntu/jenkins-agent
Labels: worker
Launch method: Launch agents via SSH
Host: 10.0.2.212
Username: ubuntu
JavaPath: /usr/bin/java
Host Key Verification Strategy: Non verifying Verification Strategy
```

Після виправлення Java version worker успішно підключився до Jenkins master.

У Jenkins log було отримано результат:

```text
Agent successfully connected and online
```

На сторінці Jenkins Nodes worker мав статус online.

## Jenkins Pipeline

Для перевірки роботи Jenkins master та Jenkins worker було розгорнуто pipeline зі Step Project 2.

Pipeline запускається саме на Jenkins worker за допомогою label:

```groovy
agent {
    label 'worker'
}
```

Jenkins job було налаштовано як:

```text
Definition: Pipeline script from SCM
SCM: Git
Repository URL: https://github.com/Di0Geen/dan-it-devops-13-practice.git
Branch Specifier: */main
Script Path: Homework/Step_project2/Src/Jenkinsfile
```

Оскільки за умовою потрібно було розгорнути той самий pipeline зі Step Project 2, у Jenkins job використовувався Jenkinsfile з папки:

```text
Homework/Step_project2/Src/Jenkinsfile
```

Копія або опис pipeline також збережені у папці:

```text
Src/jenkins/
```

## Jenkinsfile

Pipeline виконує такі етапи:

* checkout коду з GitHub;
* build Docker image;
* запуск тестів;
* login у Docker Hub;
* push Docker image у Docker Hub.

Важливе виправлення у pipeline:

```groovy
dir('Homework/Step_project2/Src') {
    sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'
}
```

Це потрібно, тому що `Dockerfile` знаходиться не в корені репозиторію, а в папці:

```text
Homework/Step_project2/Src/
```

## Docker Hub credentials

Для push Docker image у Docker Hub у Jenkins було створено credentials:

```text
Kind: Username with password
ID: dockerhub-creds
Description: DockerHub credentials
```

Цей ID використовується у Jenkinsfile:

```groovy
credentialsId: 'dockerhub-creds'
```

## Результат Jenkins Pipeline

Pipeline був успішно запущений на Jenkins worker.

У Console Output було підтверджено:

```text
Obtained Homework/Step_project2/Src/Jenkinsfile from git
Running on worker
```

Docker image був успішно зібраний:

```bash
docker build -t di0geen/forstep2:latest .
```

Тести були успішно виконані:

```text
Tests passed
```

Docker image був успішно запушений у Docker Hub:

```text
Pushed
latest: digest: sha256:...
```

Фінальний результат pipeline:

```text
Finished: SUCCESS
```

## Docker Hub

Після успішного pipeline Docker image зʼявився у Docker Hub repository:

```text
di0geen/forstep2
```

Tag:

```text
latest
```

У Docker Hub було видно, що image був оновлений після запуску Jenkins pipeline.

## Виконані Terraform-команди

Спочатку було створено S3 bucket для Terraform state.

Команди виконувалися з папки:

```text
Src/terraform/bootstrap/
```

Було виконано:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Після цього основна інфраструктура створювалася з папки:

```text
Src/terraform/infra/
```

Було виконано:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Після `terraform apply` було створено Jenkins master, Jenkins worker та всю мережеву інфраструктуру.

## Виконані Ansible-команди

Ansible-команди виконувалися з папки:

```text
Src/ansible/
```

Перевірка доступності Jenkins master:

```bash
ansible all -m ping
```

Запуск playbook:

```bash
ansible-playbook install_jenkins_nginx.yml
```

У результаті на Jenkins master було встановлено:

Jenkins;
Nginx;
reverse proxy configuration.

## Основні перевірки

Після створення та налаштування інфраструктури було виконано такі перевірки:

Jenkins master доступний через браузер;
Nginx reverse proxy працює;
Jenkins worker підключений і має статус online;
SSH з master до worker працює;
Java 21 встановлена на worker;
Docker працює на worker;
Docker Compose plugin працює на worker;
Docker test container `hello-world` запускається;
Jenkins pipeline запускається на worker;
Docker image успішно збирається;
тести успішно проходять;
Docker image успішно пушиться у Docker Hub.

## Помилки, які були виправлені

Під час виконання роботи були знайдені та виправлені такі помилки:

### 1. Jenkins worker не підключався через Java version

Помилка:

```text
UnsupportedClassVersionError
class file version 65.0
this version of the Java Runtime only recognizes class file versions up to 61.0
```

Причина: на worker була встановлена Java 17, а Jenkins agent вимагав Java 21.

Виправлення:

```bash
sudo apt update
sudo apt install -y openjdk-21-jdk
java -version
```

### 2. Jenkins сприймав Repository URL як Groovy code

Помилка:

```text
WorkflowScript: unexpected token: URL
Repository URL: https://github.com/...
```

Причина: у Jenkins job було неправильно вибрано тип pipeline.

Виправлення:

```text
Definition: Pipeline script from SCM
```

### 3. Dockerfile не знаходився

Помилка:

```text
Dockerfile: no such file or directory
```

Причина: Jenkins шукав Dockerfile у корені workspace, а Dockerfile знаходився у папці `Homework/Step_project2/Src`.

Виправлення у Jenkinsfile:

```groovy
dir('Homework/Step_project2/Src') {
    sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'
}
```

### 4. Jenkins не знаходив DockerHub credentials

Помилка:

```text
Could not find credentials entry with ID 'dockerhub-creds'
```

Причина: у Jenkins не було створено credentials з потрібним ID.

Виправлення: створено Jenkins credentials з ID:

```text
dockerhub-creds
```

## Видалення інфраструктури

Після перевірки роботи Jenkins, worker node, pipeline та Docker Hub push усі створені AWS-ресурси були видалені.

Спочатку видаляється основна інфраструктура.

Команди виконуються з папки:

```text
Src/terraform/infra/
```

Команда:

```bash
terraform destroy
```

Очікуваний результат:

```text
Destroy complete!
```

Після цього можна видалити S3 bucket для Terraform state.

Команди виконуються з папки:

```text
Src/terraform/bootstrap/
```

Якщо bucket містить state-файли, перед видаленням його потрібно очистити:

```bash
aws s3 rm s3://di0geen-step-project-3-tfstate-406026ea --recursive
```

Потім виконати:

```bash
terraform destroy
```

У результаті було видалено:

Jenkins master EC2 instance;
Jenkins worker EC2 Spot instance;
Security Groups;
NAT Gateway;
Elastic IP;
Internet Gateway;
Route Tables;
public subnet;
private subnet;
VPC;
S3 bucket для Terraform state.

## Висновок

У результаті виконання Step Project 3 було створено повну AWS-інфраструктуру для Jenkins master та Jenkins worker.

Terraform створив S3 bucket для remote state, VPC, public і private subnets, Internet Gateway, NAT Gateway, Security Groups та EC2 instances.

Ansible встановив Jenkins і Nginx reverse proxy на Jenkins master.

Jenkins worker був підключений до Jenkins master через SSH і успішно перейшов у статус online.

Після цього було розгорнуто pipeline зі Step Project 2. Pipeline виконувався саме на Jenkins worker, зібрав Docker image, запустив тести та успішно запушив image у Docker Hub.

Після завершення перевірки всі створені AWS-ресурси були видалені за допомогою `terraform destroy`.