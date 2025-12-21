# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "~> 21.0"

#   name               = var.name
#   kubernetes_version = var.kubernetes_version

#   # Optional
#   endpoint_public_access = true

#   # Optional: Adds the current caller identity as an administrator via cluster access entry
#   enable_cluster_creator_admin_permissions = true
#   authentication_mode                      = "API_AND_CONFIG_MAP"

#   compute_config = {
#     enabled    = true
#     node_pools = ["general-purpose"]
#   }

#   upgrade_policy = {
#     support_type = "STANDARD"
#   }

#   vpc_id     = module.vpc.vpc_id
#   subnet_ids = module.vpc.private_subnets

#   tags = {
#     Environment       = "dev"
#     Terraform         = "true"
#     Application       = var.name
#     Custodian         = "Present"
#     CustodianOffHours = "Default"
#   }
# }