output "account_id" {
  description = "AWS Account ID"
  value = var.account_id
}

output "vpc_id" {
  description = "VPC ID"
  value = var.vpc_id
}

output "cluster_name" {
  description = "EKS cluster name"
  value = aws_eks_cluster.this.name
}

output "cluster_version" {
  description = "EKS cluster name"
  value = aws_eks_cluster.this.version
}