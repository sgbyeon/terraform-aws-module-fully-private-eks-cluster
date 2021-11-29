# Gateway type VPC endpoint for EKS
resource "aws_vpc_endpoint" "gateway" {
  vpc_id = var.vpc_id
  for_each = toset(keys({ for k, v in var.endpoints : k => v if v == "Gateway" }))
  service_name = format("com.amazonaws.%s.%s", var.region, each.key)

  vpc_endpoint_type = var.endpoints[each.key]

  route_table_ids = [
    var.private_route_tables
  ] 

  tags = merge(var.tags, tomap({Name = format("%s-%s-%s-endpoint", var.prefix, var.vpc_id, each.key)}))
}

# Interface type VPC endpoint for EKS
resource "aws_vpc_endpoint" "interface" {
  vpc_id = var.vpc_id
  for_each = toset(keys({ for k, v in var.endpoints : k => v if v == "Interface" }))
  service_name = format("com.amazonaws.%s.%s", var.region, each.key)
  private_dns_enabled = true

  vpc_endpoint_type = var.endpoints[each.key]

  subnet_ids = [
    var.private_subnet_ids
  ]

  security_group_ids = [
    aws_security_group.vpce.id
  ]

  tags = merge(var.tags, tomap({Name = format("%s-%s-%s-endpoint", var.prefix, var.vpc_id, each.key)}))
}