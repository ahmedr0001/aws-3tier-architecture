output "frontend_public_ip" {
  description = "The public IP address of the frontend server"
  value       = aws_instance.frontend.public_ip
}

output "backend_private_ip" {
  description = "The private IP address of the backend server"
  value       = aws_instance.backend.private_ip
}

output "db_private_ip" {
  description = "The private IP address of the database server"
  value       = aws_instance.db.private_ip
}