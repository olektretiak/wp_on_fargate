# Define an AWS EFS (Elastic File System) file system resource.
resource "aws_efs_file_system" "this" {
  creation_token = "${var.prefix}-${var.environment}"  # A unique identifier for the EFS file system
  tags           = var.tags
}

# Define AWS EFS mount targets for each private subnet.
resource "aws_efs_mount_target" "this" {
  count          = length(module.vpc.private_subnets)
  file_system_id = aws_efs_file_system.this.id
  subnet_id      = module.vpc.private_subnets[count.index]
  security_groups = [
    aws_security_group.efs.id
  ]
}

# Define an AWS security group for the EFS file system.
resource "aws_security_group" "efs" {
  name        = "${var.prefix}-efs-${var.environment}"
  description = "Allow traffic from self"
  vpc_id      = module.vpc.vpc_id

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound NFS traffic from the same security group.
  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"
    self      = true
  }
  
  tags = var.tags
}
