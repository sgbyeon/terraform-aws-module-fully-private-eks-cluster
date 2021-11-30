# AWS VPC Terraform custom module
* Fully private EKS cluster 세팅 커스텀 모듈
* EKS endpoint API 의 public 허용을 금지(보안강화)
* Node Group은 EKS control plane에 접속하기 위해 VPC Endpoint를 사용(NAT Gateway 사용하지 않음)

## Usage

### `terraform.tfvars`
* 모든 변수는 적절하게 변경하여 사용
```
account_id = ["123456789012"] # 아이디 변경 필수, output 확인용, 실수 방지용도, 리소스에 사용하진 않음
region = "ap-northeast-2"
prefix = "bsg-demo"
cluster_name = "fully-private-eks-cluster" # 실제 클러스터 이름은 ${prefix}-${cluser_name}
cluster_version = "1.21"
service_ipv4_cidr = "172.16.0.0/16" # Cluster Service Ipv4 CIDR, Pod가 할당 받을 IP 대역
bastion_ipv4_cidr = ["10.0.1.0/24", "10.0.2.0/24"] # node-group의 EC2 인스턴스의 ssh 접속을 위한 대역

cluster_endpoint_public_access = "false" # EKS endpoint API에 퍼블릭 허용 금지(보안강화)
cluster_endpoint_private_access = "true"

# EKS node group이 배치 될 VPC의 TAG, data에서 tag 기반으로 for_each
vpc_filters = {
  "Name" = "bsg-demo-eks-vpc"
}

# Node Group이 EKS control plane에 붙기 위해 NAT Gateway를 사용하지 않기 위해 vpc endpoint 생성
endpoints = {
  "s3" = "Gateway"
  "ecr.api" = "Interface"
  "ecr.dkr" = "Interface" # ECR Docker
  "ec2" = "Interface" 
  "logs" = "Interface" # CloudWatch
  "sts" = "Interface"
}

enable_eks_log_types = [] # cloudwatch log-group은 비용이 비싸기 때문에 필요한 로그만 추가해서 사용 권장
#enable_eks_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

# 공통 tag, 생성되는 모든 리소스에 태깅
tags = {
    "CreatedByTerraform" = "true"
}
```
---

### `main.tf`
```
module "cluster" {
  source = "git::https://github.com/sgbyeon/terraform-aws-module-fully-private-eks-cluster.git"
  account_id = var.account_id
  region = var.region
  prefix = var.prefix
  cluster_name = var.cluster_name
  cluster_version = var.cluster_version
  service_ipv4_cidr = var.service_ipv4_cidr
  bastion_ipv4_cidr = var.bastion_ipv4_cidr
  cluster_endpoint_public_access = var.cluster_endpoint_public_access
  endpoints = var.endpoints
  vpc_id = data.aws_vpc.this.id
  private_subnet_ids = data.aws_subnet_ids.private.ids
  private_route_tables = data.aws_route_tables.private.ids
  tags = var.tags
}
```
---

### `provider.tf`
```
provider  "aws" {
  region  =  var.region
}
```
---

### `terraform.tf`
```
terraform {
  required_version = ">= 0.15.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.39"
    }
  }
}
```
---

### `data.tf`
```
data "aws_region" "current" {}

data "aws_vpc" "this" {
  dynamic "filter" {
    for_each = var.vpc_filters # block를 생성할 정보를 담은 collection 전달, 전달 받은 수 만큼 block 생성
    iterator = tag # 각각의 item 에 접근할 수 있는 라벨링 부여, content block에서 tag 를 사용하여 접근
    
    content { # block안에서 실제 전달되는 값들
      name = "tag:${tag.key}"
      values = [
        tag.value
      ]
    }
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.this.id

  tags = {
    Tier = "private" # Tier 태그가 private 서브넷만 추출
  }
  #filter {
  #  name = "tag:Tier"
  #  values = ["private"]
  #}
}

data "aws_route_tables" "private" {
  vpc_id = data.aws_vpc.this.id

  tags = {
    Tier = "private" # Tier 태그가 private 서브넷만 추출
  }
  #filter {
  #  name = "tag:Tier"
  #  values = ["private"]
  #}
}
```
---

### `variables.tf`
```
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
  description = "eks cluster name"
  type = string
  default = ""
}

variable "cluster_version" {
  description = "eks cluster version"
  type = string
  default = ""
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

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type = bool
  default = false
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  type = bool
  default = true
}

variable "vpc_filters" {
  description = "Filters to select subnets"
  type = map(string)
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
variable "tags" {
  description = "tag map"
  type = map(string)
}
```
---

### `outputs.tf`
```
output "account_id" {
  description = "AWS Account ID"
  value = module.cluster.account_id
}

output "vpc_id" {
  description = "VPC ID"
  value = module.cluster.vpc_id
}

output "cluster_name" {
  description = "EKS cluster name"
  value = module.cluster.cluster_name
}
```