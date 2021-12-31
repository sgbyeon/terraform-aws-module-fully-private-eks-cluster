resource "aws_eks_cluster" "this" {
  name = format("%s-%s-eks", var.prefix, var.cluster_name)
  version = var.cluster_version
  role_arn = aws_iam_role.this.arn

  vpc_config {
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access = var.cluster_endpoint_public_access
    subnet_ids = var.private_subnet_ids
    security_group_ids = [aws_security_group.eks_add_sg.id]
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.service_ipv4_cidr
  }

  enabled_cluster_log_types = var.enable_eks_log_types

  depends_on = [
    aws_vpc_endpoint.gateway,
    aws_vpc_endpoint.interface,
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController
  ]

  tags = merge(var.tags, tomap({Name = format("%s.%s.eks", var.prefix, var.cluster_name)}))
}