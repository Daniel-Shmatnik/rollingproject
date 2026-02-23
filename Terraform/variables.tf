variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID for deployment"
  type        = string
  default     = "vpc-044604d0bfb707142"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "builder"
}

# Optional: Tester can provide these, otherwise auto-detected
variable "subnet_id" {
  description = "Subnet ID (optional - auto-discovered if not provided)"
  type        = string
  default     = ""
}

variable "my_ip" {
  description = "Your IP address for SSH access (optional - auto-detected if not provided)"
  type        = string
  default     = ""
}

variable "ssh_public_key_path" {
  description = "Path to existing SSH public key (optional - generates new key if not provided)"
  type        = string
  default     = ""
}