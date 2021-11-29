variable "account_id" {
  description = "List of Allowed AWS account IDs"
  type = list(string)
  default = [""]
}

variable "region" {
  description = "AWS Region"
  type = string
  default = ""
}

variable "prefix" {
  description = "prefix for aws resources and tags"
  type = string
}

variable "cluster_name" {
  description = "Name for EKS Cluster "
  type = string
}

variable "cluster_version" {
  description = "Kubernetes Version for EKS Cluster "
  type = string
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type = bool
  default = false
}

variable "cluster_endpoint_private_access" {
  description = "Allow access through private API"
  type = bool
  default = true
}

variable "service_ipv4_cidr" {
  description = "CIDR to assign k8s service ip"
  type = string
}

variable "bastion_ipv4_cidr" {
  description = "Bastion connect to K8s endpoint"
  type = list(string)
  default = [""]
}

variable "vpc_id" {
  description = "vpc id"
  type = string
}

variable "endpoints" {
  description = "VPC endpoints"
  type = map(string)
}

variable "enable_eks_log_types" {
  description = "EKS control plane logs"
  type = list(string)
  default = []
}

variable "private_subnet_ids" {
  description = "private subnet IDs"
  type = list(string)
}

variable "private_route_tables" {
  description = "private route table IDs"
  type = list(string)
}

variable "tags" {
  description = "tag map"
  type = map(string)
}