# # Create VPC using a module
# module "vpc" {
#   source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=c182453f881ae77afd14c826dc8e23498b957907" # commit hash of version 5.7.1

#   name = var.vpc_name
#   cidr = var.vpc_cidr

#   azs            = ["us-east-1a", "us-east-1b", "us-east-1c"]
#   public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

#   enable_dns_hostnames   = true
#   one_nat_gateway_per_az = false

#   map_public_ip_on_launch = true

#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#     Name        = var.vpc_name
#   }
# }
