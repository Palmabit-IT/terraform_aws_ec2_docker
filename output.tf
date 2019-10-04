output "ids" {
  description = "List of IDs of instances"
  value       = aws_instance.app.id
}

output "public_dns" {
  description = "List of public DNS names assigned to the instances"
  value       = aws_instance.app.public_dns
}

output "vpc_security_group_ids" {
  description = "List of VPC security group ids assigned to the instances"
  value       = aws_instance.app.vpc_security_group_ids
}

output "tags" {
  description = "List of tags"
  value       = aws_instance.app.tags
}

output "placement_group" {
  description = "List of placement group"
  value       = aws_instance.app.placement_group
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.app.id
}

output "instance_public_ip" {
  description = "Public IP address assigned to the EC2 instance"
  value       = aws_instance.app.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name assigned to the EC2 instance"
  value       = aws_instance.app.public_dns
}

output "credit_specification" {
  description = "Credit specification of EC2 instance"
  value       = aws_instance.app.credit_specification
}

output "public_key_filename" {
  description = "SSH public key filename"
  value       = module.ssh_key_pair.public_key_filename
}

output "public_key" {
  description = "SSH public key"
  value       = module.ssh_key_pair.public_key
}
