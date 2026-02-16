# Auto-detect public IP if not provided
data "http" "my_ip" {
  count = var.my_ip == "" ? 1 : 0
  url   = "https://checkip.amazonaws.com/"
}

# Find public subnets if subnet_id not provided
data "aws_subnets" "public_subnets" {
  count = var.subnet_id == "" ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

# Find latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Generate SSH key if not provided
resource "tls_private_key" "ssh_key" {
  count     = var.ssh_public_key_path == "" ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private key locally if generated
resource "local_file" "private_key" {
  count           = var.ssh_public_key_path == "" ? 1 : 0
  content         = tls_private_key.ssh_key[0].private_key_pem
  filename        = "${path.module}/builder_key.pem"
  file_permission = "0600"
}

# Create AWS key pair (use provided or generated key)
resource "aws_key_pair" "builder_key" {
  key_name = "builder-key"
  public_key = var.ssh_public_key_path != "" ? file(var.ssh_public_key_path) : tls_private_key.ssh_key[0].public_key_openssh

  tags = {
    Name = "builder-ssh-key"
  }
}

# Security group
resource "aws_security_group" "builder_sg" {
  name        = "builder-security-group"
  description = "Security group for builder EC2 instance"
  vpc_id      = var.vpc_id

  # SSH access - use provided IP or auto-detected
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip != "" ? var.my_ip : "${chomp(data.http.my_ip[0].response_body)}/32"]
  }

  # HTTP access on port 5001
  ingress {
    description = "HTTP for Python application"
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = [var.my_ip != "" ? var.my_ip : "${chomp(data.http.my_ip[0].response_body)}/32"]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "builder-sg"
  }
}

# EC2 instance
resource "aws_instance" "builder" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id != "" ? var.subnet_id : data.aws_subnets.public_subnets[0].ids[0]
  vpc_security_group_ids = [aws_security_group.builder_sg.id]
  key_name               = aws_key_pair.builder_key.key_name

  tags = {
    Name = var.instance_name
  }
}