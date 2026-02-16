variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID provided for the task"
  type        = string
  default     = "vpc-044604d0bfb707142"
}

variable "instance_type" {
  description = "EC2 instance type for Docker workloads"
  type        = string
  default     = "t3.medium"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "builder"
}