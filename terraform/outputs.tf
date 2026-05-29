output "frontend_public_ip" {
  value = module.compute.frontend_public_ip
}

output "backend_private_ip" {
  value = module.compute.backend_private_ip
}

output "db_private_ip" {
  value = module.compute.db_private_ip
}