output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.builder.public_ip
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.builder.id
}

output "ssh_private_key_path" {
  description = "Path to the private SSH key"
  value       = local_file.private_key.filename
  sensitive   = true
}

output "ssh_connection_command" {
  description = "Command to SSH into the instance"
  value       = "ssh -i ${local_file.private_key.filename} ubuntu@${aws_instance.builder.public_ip}"
  sensitive   = true
}