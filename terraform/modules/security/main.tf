#frontend security Groups that allow only http(s) and ssh to frontend
resource "aws_security_group" "frontend_sg" {
  name        = "3tier-frontend-sg"
  description = "Allow inbound traffic for web tiers"
  vpc_id      = var.vpc_id

  # This is the loop block
  dynamic "ingress" {
    for_each = [80, 443, 22] # The array we are looping through

    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "3tier-frontend-sg"
  }
}

#backend security groups that allows only traffic come from frontend secruity groups 
resource "aws_security_group" "backend_sg" {
  name   = "3tier-backend-sg"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = [5000, 22] # The array we are looping through

    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = [aws_security_group.frontend_sg.id]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#database security groups that allows only traffic come from backend secruity groups 
resource "aws_security_group" "db_sg" {
  name   = "3tier-db-sg"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = [5432, 22] # The array we are looping through

    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = [aws_security_group.backend_sg.id]
    }
  }

  # Allow SSH from the Frontend Security Group for Ansible ProxyJump
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}