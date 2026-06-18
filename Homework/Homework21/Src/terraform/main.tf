provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_key_pair" "homework21" {
  key_name   = "homework21-key"
  public_key = file(pathexpand(var.public_key_path))

  tags = {
    Name     = "homework21-key"
    Homework = "21"
  }
}

resource "aws_security_group" "homework21" {
  name        = "homework21-sg"
  description = "Allow SSH and HTTP for Homework21"
  vpc_id      = data.aws_vpc.default.id

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

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name     = "homework21-sg"
    Homework = "21"
  }
}

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

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.ini"

  content = <<-EOF
[web]
%{for instance in aws_instance.web~}
${instance.tags.Name} ansible_host=${instance.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${pathexpand(var.private_key_path)}
%{endfor~}

[web:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF

  depends_on = [aws_instance.web]
}