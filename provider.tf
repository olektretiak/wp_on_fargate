# Configures the default AWS provider.
provider "aws" {
}

# Specifies that the Terraform state file should be stored in an S3 bucket.
terraform {
  backend "s3" {
    # The name of the S3 bucket where the Terraform state file will be stored.
    bucket = "tf-back-otretiak"

    # The key (path) within the S3 bucket where the Terraform state file will be stored.
    key    = "wordpress"
  }
}

# Configures an additional AWS provider with an alias and a specific region.
provider "aws" {
  # Alias for this provider configuration. This allows us to have multiple configurations for the same provider.
  alias   = "us_east_1"

  # The AWS region in which the resources will be created.
  region  = "us-east-1"
}

# Configures the Random provider, which is used to generate random values for resource attributes.
provider "random" {
}
