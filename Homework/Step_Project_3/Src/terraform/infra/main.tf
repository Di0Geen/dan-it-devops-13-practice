data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "main" {
  key_name   = var.key_name
  public_key = file(pathexpand(var.public_key_path))

  tags = {
    Name    = "${var.project_name}-key"
    Project = "Step Project 3"
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = "Step Project 3"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project_name}-public-subnet-jenkins-master"
    Project = "Step Project 3"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name    = "${var.project_name}-private-subnet-jenkins-worker"
    Project = "Step Project 3"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = "Step Project 3"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name    = "${var.project_name}-nat-eip"
    Project = "Step Project 3"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name    = "${var.project_name}-nat-gateway"
    Project = "Step Project 3"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name    = "${var.project_name}-public-route-table"
    Project = "Step Project 3"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name    = "${var.project_name}-private-route-table"
    Project = "Step Project 3"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "jenkins_master" {
  name        = "${var.project_name}-jenkins-master-sg"
  description = "Security group for Jenkins master"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "HTTP access through nginx reverse proxy"
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
    Name    = "${var.project_name}-jenkins-master-sg"
    Project = "Step Project 3"
  }
}

resource "aws_security_group" "jenkins_worker" {
  name        = "${var.project_name}-jenkins-worker-sg"
  description = "Security group for Jenkins worker"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "SSH from Jenkins master only"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_master.id]
  }

  egress {
    description = "Allow all outbound traffic through NAT Gateway"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-jenkins-worker-sg"
    Project = "Step Project 3"
  }
}

resource "aws_instance" "jenkins_master" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.master_instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.jenkins_master.id]
  key_name                    = aws_key_pair.main.key_name
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user_data_master.sh.tpl", {
    public_key = file(pathexpand(var.public_key_path))
  })

  tags = {
    Name    = "${var.project_name}-jenkins-master"
    Project = "Step Project 3"
    Type    = "on-demand"
  }
}

resource "aws_instance" "jenkins_worker" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.worker_instance_type
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.jenkins_worker.id]
  key_name                    = aws_key_pair.main.key_name
  associate_public_ip_address = false

  instance_market_options {
    market_type = "spot"

    spot_options {
      spot_instance_type             = "one-time"
      instance_interruption_behavior = "terminate"
    }
  }

  user_data = templatefile("${path.module}/user_data_worker.sh.tpl", {
    public_key = file(pathexpand(var.public_key_path))
  })

  tags = {
    Name    = "${var.project_name}-jenkins-worker"
    Project = "Step Project 3"
    Type    = "spot"
  }
}