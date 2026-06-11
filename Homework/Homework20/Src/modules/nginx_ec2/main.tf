data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

resource "aws_security_group" "nginx_sg" {
  name        = "homework20-nginx-sg"
  description = "Security group for Homework20 Nginx EC2"
  vpc_id      = var.vpc_id

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

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name     = "homework20-nginx-sg"
    Homework = "Homework20"
  }
}

resource "aws_instance" "nginx" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnets.selected.ids[0]
  vpc_security_group_ids      = [aws_security_group.nginx_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install nginx -y
              systemctl enable nginx
              systemctl start nginx
              echo "<h1>Hello from Homework20 Terraform Nginx</h1>" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name     = "homework20-nginx-ec2"
    Homework = "Homework20"
  }
}