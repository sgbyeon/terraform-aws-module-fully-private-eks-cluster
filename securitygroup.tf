# security group for EKS
resource "aws_security_group" "eks_add_sg" {
  name = "${var.prefix}.${var.cluster_name}.eks.additional-security-groups"
  description = "${var.prefix}.${var.cluster_name}.eks.additional-security-group"
  vpc_id = var.vpc_id

  tags = merge(var.tags, tomap({
    Name = format("%s.%s.eks.additional-security-groups", var.prefix, var.cluster_name),
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }))
}

resource "aws_security_group_rule" "cluster_inbound_from_self" {
  description  = "Allow worker nodes to communicate with the cluster API Server"
  from_port  = 0
  protocol  = "-1"
  security_group_id  = aws_security_group.eks_add_sg.id
  source_security_group_id = aws_security_group.eks_add_sg.id
  to_port  = 65535
  type  = "ingress" 
}

resource "aws_security_group_rule" "cluster_inbound_from_nodegroup" {
  description  = "Allow worker nodes to communicate with the cluster API Server"
  from_port  = 443
  protocol  = "tcp"
  security_group_id  = aws_security_group.eks_add_sg.id
  to_port  = 443
  type  = "ingress"
  cidr_blocks = var.bastion_ipv4_cidr
}

# security group for vpc endpoint
resource "aws_security_group" "vpce" {
  name = format("%s.%s.vpce.security-groups", var.prefix, var.cluster_name)
  vpc_id = var.vpc_id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, tomap({Name = format("%s.%s.vpce.security-groups", var.prefix, var.cluster_name)}))
}

resource "aws_security_group_rule" "vpce" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = sort(concat(var.private_subnet_cidr, var.bastion_ipv4_cidr))
  security_group_id = aws_security_group.vpce.id
}