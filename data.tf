# Retrieve the current AWS region.
data "aws_region" "current" {}

# Retrieve information about the current AWS caller identity.
data "aws_caller_identity" "current" {}

# Retrieve a list of availability zones for the current region.
data "aws_availability_zones" "this" {}