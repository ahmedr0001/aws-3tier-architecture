# Instantiate the Network Module
module "network" {
  source = "./modules/network"
}

# Instantiate the Security Module and feed it the Network Output
module "security" {
  source = "./modules/security"
  #give the var in security module it's value from network module
  vpc_id = module.network.vpc_id
}

#read key generated locally this more secure ssh-keygen -t rsa -b 4096 -f ~/.ssh/3tier-key
resource "aws_key_pair" "main" {
  key_name   = "3tier-ssh-key"
  public_key = file("~/.ssh/3tier-key.pub")
}

# Instantiate the Compute Module
module "compute" {
  source = "./modules/compute"

  # Injecting the Network Subnets
  public_subnet_id      = module.network.public_subnet_id
  private_app_subnet_id = module.network.private_app_subnet_id
  private_db_subnet_id  = module.network.private_db_subnet_id

  # Injecting the Security Groups
  frontend_sg_id = module.security.frontend_sg_id
  backend_sg_id  = module.security.backend_sg_id
  db_sg_id       = module.security.db_sg_id

  # Injecting the SSH Key Name!
  key_name = aws_key_pair.main.key_name
}

# Generate Ansible Inventory
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    frontend_ip = module.compute.frontend_public_ip
    backend_ip  = module.compute.backend_private_ip
    db_ip       = module.compute.db_private_ip
  })
  filename = "${path.module}/../ansible/inventory.ini"
}

# Generate Ansible Variables for Database Role
resource "local_file" "ansible_db_vars" {
  content = templatefile("${path.module}/db_vars.tpl", {
    backend_ip = module.compute.backend_private_ip
  })
  filename = "${path.module}/../ansible/roles/database/vars/main.yml"
}

# Generate Ansible Variables for Backend Role
resource "local_file" "ansible_backend_vars" {
  content = templatefile("${path.module}/backend_vars.tpl", {
    db_ip = module.compute.db_private_ip
  })
  filename = "${path.module}/../ansible/roles/backend/vars/main.yml"
}

# Generate Ansible Variables for Frontend Role
resource "local_file" "ansible_frontend_vars" {
  content = templatefile("${path.module}/frontend_vars.tpl", {
    backend_ip = module.compute.backend_private_ip
  })
  filename = "${path.module}/../ansible/roles/frontend/vars/main.yml"
}