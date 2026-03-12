# Main VPC for the App
resource "aws_vpc" "main" {
  cidr_block = var.vpc-cidr-block

  tags = merge(
    local.common_tags,
    {
    Name = "${var.environment}-VPC"
    }
  )
}

# Public subnet 1 to host ALB
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc-cidr-block, 8, var.subnet-index-public)
  availability_zone = var.availability-zone
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
    Name = "${var.environment}-Public-Subnet"
    }
  )
}

# Public subnet 2 to host ALB
resource "aws_subnet" "public-2" {
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc-cidr-block, 8, var.subnet-index-public-2)
  availability_zone = var.availability-zone-2
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
    Name = "${var.environment}-Public-Subnet-2"
    }
  )
}

# Internet gateway for the public subnets to access the internet
resource "aws_internet_gateway" "public-IGW" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
    Name = "${var.environment}-IGW"
    }
  )
}

# Route table for the public subnets
resource "aws_route_table" "public-RT" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public-IGW.id
  }

  tags = merge(
    local.common_tags,
    {
    Name = "${var.environment}-Public-RT"
    }
  )
}

# Associating the route table to public subnet 1
resource "aws_route_table_association" "public-RTA" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public-RT.id
}

# Associating the route table to public subnet 2
resource "aws_route_table_association" "public-RTA-2" {
  subnet_id = aws_subnet.public-2.id
  route_table_id = aws_route_table.public-RT.id
}

# Private subnet to host ECS for the App
resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc-cidr-block, 4, var.subnet-index-private)
  availability_zone = var.availability-zone

  tags = merge(
    local.common_tags,
    {
    Name = "${var.environment}-Private-Subnet-1"
    }
  )
}

# Private subnet 2 to host ECS for the App
resource "aws_subnet" "private-2" {
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc-cidr-block, 4, var.subnet-index-private-2)
  availability_zone = var.availability-zone-2

  tags = merge(
    local.common_tags,
    {
    Name = "${var.environment}-Private-Subnet-2"
    }
  )
}

# Elastic IP address for the Nat Gateway
resource "aws_eip" "nat-eip" {
  domain = "vpc"
  
  tags = merge(
    local.common_tags,
    {
    Name = "${var.environment}-NAT-EIP"
    }
  )
}

# Elastic IP address for the Nat Gateway 2
resource "aws_eip" "nat-eip-2" {
  domain = "vpc"
  
  tags = merge(
    local.common_tags,
    {
    Name = "${var.environment}-NAT-EIP-2"
    }
  )
}

# Nat Gateway for the private subnet
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id = aws_subnet.public.id

  tags = merge(
    local.common_tags,
    {
    Name = "${var.environment}-NAT-GW"
    }
  )
}

# Nat Gateway for the private subnet 2
resource "aws_nat_gateway" "main-2" {
  allocation_id = aws_eip.nat-eip-2.id
  subnet_id = aws_subnet.public-2.id

  tags = merge(
    local.common_tags,
    {
    Name = "${var.environment}-NAT-GW-2"
    }
  )
}

# Route table for the Private subnet
resource "aws_route_table" "private-RT" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = merge(
    local.common_tags,
    {
    Name = "${var.environment}-Private-RT"
    }
  )
}

# Route table for the Private subnet 2
resource "aws_route_table" "private-RT-2" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main-2.id
  }
  tags = merge(
    local.common_tags,
    {
    Name = "${var.environment}-Private-RT-2"
    }
  )
}

# Associating the route table to the private subnet 1
resource "aws_route_table_association" "private-RTA" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private-RT.id
}

# Associating the route table to the private subnet 2
resource "aws_route_table_association" "private-RTA-2" {
  subnet_id = aws_subnet.private-2.id
  route_table_id = aws_route_table.private-RT-2.id
}