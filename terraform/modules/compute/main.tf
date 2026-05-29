#Frontend EC2 Instance (Nginx Web Server)
resource "aws_instance" "frontend" {
  ami                    = "ami-091138d0f0d41ff90"
  instance_type          = "t3.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.frontend_sg_id]
  key_name               = var.key_name

  tags = {
    Name = "3tier-frontend"
  }
}

#Backend EC2 Instance ()
resource "aws_instance" "backend" {
  ami                    = "ami-091138d0f0d41ff90"
  instance_type          = "t3.micro"
  subnet_id              = var.private_app_subnet_id
  vpc_security_group_ids = [var.backend_sg_id]
  key_name               = var.key_name

  tags = {
    Name = "3tier-backend"
  }
}

#DB EC2 Instance ()
resource "aws_instance" "db" {
  ami                    = "ami-091138d0f0d41ff90"
  instance_type          = "t3.micro"
  subnet_id              = var.private_db_subnet_id
  vpc_security_group_ids = [var.db_sg_id]
  key_name               = var.key_name

  tags = {
    Name = "3tier-DB"
  }
}