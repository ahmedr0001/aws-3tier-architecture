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

# # Generate a secure private key natively in Terraform like do ssh-keygen -t rsa -b 4096
# resource "tls_private_key" "main" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# # Upload the public key to AWS to create the Key Pair
# resource "aws_key_pair" "main" {
#   key_name   = "3tier-ssh-key"
#   public_key = tls_private_key.main.public_key_openssh
# }

# # Save the private key to your local laptop so Ansible can use it
# resource "local_file" "private_key" {
#   content         = tls_private_key.main.private_key_pem
#   filename        = "${path.module}/3tier-ssh-key.pem"
#   file_permission = "0400" # Sets strict read-only permissions required by SSH
# }

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
