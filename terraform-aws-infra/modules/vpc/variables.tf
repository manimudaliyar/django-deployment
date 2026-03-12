variable "vpc-cidr-block" {
  description = "CIDR block for VPC"
  type = string
}

variable "environment" {
  description = "Environment in which the infra is provisioned for"
  type = string
}

variable "project-owner" {
  description = "Owner of this project"
  type = string
}

variable "subnet-index-public" {
    description = "Subnet index for public subnet CIDR"
    type = number
}

variable "subnet-index-public-2" {
    description = "Subnet index for second public subnet CIDR"
    type = number
}

variable "subnet-index-private" {
    description = "Subnet index for private subnet CIDR"
    type = number
}

variable "subnet-index-private-2" {
    description = "Subnet index for second private subnet CIDR"
    type = number
}

variable "availability-zone" {
  description = "Availability zone for public subnet"
  type = string
}

variable "availability-zone-2" {
  description = "Availability zone for second public subnet"
  type = string
}