# Output variable for the VPC
output "vpc-id" {
  value = aws_vpc.main.id
}

# Output variables for the public subnet 1
output "public-subnet-1-id" {
  value = aws_subnet.public.id
}

# Output variables for the public subnet 2
output "public-subnet-2-id" {
  value = aws_subnet.public-2.id
}

# Output variables for the private subnet 1
output "private-subnet-1-id" {
  value = aws_subnet.private.id
}

# Output variables for the private subnet 2
output "private-subnet-2-id" {
  value = aws_subnet.private-2.id
}