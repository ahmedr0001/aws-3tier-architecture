resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "3tier-vpc"
  }
}


#three subnets one public for frontend and 2 private for app and db

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true #to make sure this subnet will get an ip

  tags = {
    Name = "3tier-public-subnet"
  }
}

resource "aws_subnet" "private_app" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"


  tags = {
    Name = "3tier-private_app-subnet"
  }
}

resource "aws_subnet" "private_db" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"


  tags = {
    Name = "3tier-private_db-subnet"
  }
}

#internet gatway to allow public subnet reach internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "3tier-igw"
  }
}

#Elastic IP to give it to nat gatway 
resource "aws_eip" "nat_eip" {
  domain = "vpc" #mean this eip will used for vpc no ec2
  tags = {
    Name = "3tier-nat-eip"
  }
}

#nat gatway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id #NAt gatway must live in public subnet to be able reach internet

  tags = {
    Name = "3tier-nat"
  }
  depends_on = [aws_internet_gateway.igw]
}


#routing table for public subnet that forward any traffic to internet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "3tier_public_rt"
  }
}


#routing table for private subnets
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "3tier_private_rt"
  }
}

# Public Subnet Association used to link routing table to subnet 
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# Private App Subnet Association 
resource "aws_route_table_association" "private_app_assoc" {
  subnet_id      = aws_subnet.private_app.id
  route_table_id = aws_route_table.private_rt.id
}

# Private DB Subnet Association 
resource "aws_route_table_association" "private_db_assoc" {
  subnet_id      = aws_subnet.private_db.id
  route_table_id = aws_route_table.private_rt.id
}