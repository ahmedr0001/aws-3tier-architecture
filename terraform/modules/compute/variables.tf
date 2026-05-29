variable "public_subnet_id" {
  type        = string
  description = "ID of the public subnet for the frontend"
}

variable "private_app_subnet_id" {
  type        = string
  description = "ID of the private app subnet for the backend"
}

variable "private_db_subnet_id" {
  type        = string
  description = "ID of the private db subnet for the database"
}

variable "frontend_sg_id" {
  type        = string
  description = "ID of the frontend security group"
}

variable "backend_sg_id" {
  type        = string
  description = "ID of the backend security group"
}

variable "db_sg_id" {
  type        = string
  description = "ID of the database security group"
}

#key that will used to ssh EC2
variable "key_name" {
  type        = string
  description = "The name of the SSH key pair to allow login access"
}