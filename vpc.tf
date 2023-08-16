# Create a VPC using the "terraform-aws-modules/vpc/aws" module
module "vpc" {
  source                 = "terraform-aws-modules/vpc/aws"  # Use the VPC module from the Terraform Registry
  name                   = "${var.prefix}-${var.environment}"  # Name for the VPC
  cidr                   = var.vpc_cidr  # CIDR block for the VPC
  azs                    = data.aws_availability_zones.this.names  # Availability zones to spread subnets across
  private_subnets        = var.private_subnet_cidrs  # CIDR blocks for private subnets
  public_subnets         = var.public_subnet_cidrs  # CIDR blocks for public subnets
  enable_nat_gateway     = true  # Enable NAT gateways for private subnets
  single_nat_gateway     = false  # Use multiple NAT gateways (one per AZ)
  one_nat_gateway_per_az = false  # Use a single NAT gateway for all private subnets
  tags                   = var.tags  # Tags to apply to resources created by the module
  version                = "~>5.0"  # Use module version 5.0 or later
  enable_dns_hostnames   = true  # Enable DNS hostnames in the VPC
}
