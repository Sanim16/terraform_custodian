# output "instance_public_ip" {
#   description = "Public IP of the instance"
#   value       = aws_instance.main.public_ip
# }

# output "cluster_endpoint" {
#   description = "Endpoint for EKS control plane"
#   value       = module.eks.cluster_endpoint
# }

# output "region" {
#   description = "AWS region"
#   value       = var.region
# }

# output "cluster_name" {
#   description = "Kubernetes Cluster Name"
#   value       = module.eks.cluster_name
# }