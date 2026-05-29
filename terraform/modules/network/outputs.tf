output "vpc_id" {
  description = "The ID of the main VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet for the frontend"
  value       = aws_subnet.public.id
}

output "private_app_subnet_id" {
  description = "The ID of the private application subnet for the backend"
  value       = aws_subnet.private_app.id
}

output "private_db_subnet_id" {
  description = "The ID of the private database subnet for the database tier"
  value       = aws_subnet.private_db.id
}