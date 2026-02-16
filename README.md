# EC2 Docker Builder

Terraform configuration to create an Ubuntu EC2 instance with Docker pre-installed.

## What Gets Created

- EC2 instance (t3.medium) with Docker and Docker Compose
- Auto-generated SSH key pair
- Security group (SSH from your IP, HTTP on port 5001)

## Quick Start
```bash
cd terraform
terraform init
terraform apply
```

## Project Structure
```
.
├── README.md              # This file
└── terraform/
    ├── main.tf           # Infrastructure code
    ├── variables.tf      # Configuration variables
    ├── outputs.tf        # Display values
    ├── README.md         # Detailed Terraform docs
    └── .gitignore        # Git ignore rules
```

## After Deployment
```bash
# Get SSH command and connect
terraform output -raw ssh_connection_command | bash

# Verify Docker is installed
docker --version
docker compose version
```

## Configuration

- **VPC**: `vpc-044604d0bfb707142`
- **Instance**: t3.medium, Ubuntu 22.04
- **Subnet**: Public (auto-selected)

See `terraform/README.md` for detailed instructions.