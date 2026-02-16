output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.builder.public_ip
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.builder.id
}

output "ssh_private_key_path" {
  description = "Path to the private SSH key (if generated)"
  value       = var.ssh_public_key_path == "" ? local_file.private_key[0].filename : "Using provided SSH key"
  sensitive   = true
}

output "ssh_connection_command" {
  description = "Command to SSH into the instance"
  value = var.ssh_public_key_path == "" ? "ssh -i ${local_file.private_key[0].filename} ubuntu@${aws_instance.builder.public_ip}" : "ssh -i <your_private_key> ubuntu@${aws_instance.builder.public_ip}"
  sensitive   = true
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.builder_sg.id
}

output "detected_ip" {
  description = "The IP address used for SSH access"
  value       = var.my_ip != "" ? var.my_ip : "${chomp(data.http.my_ip[0].response_body)}/32"
}

output "subnet_used" {
  description = "Subnet ID where instance was launched"
  value       = aws_instance.builder.subnet_id
}