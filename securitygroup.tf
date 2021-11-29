resource "aws_security_group" "eks_add_sg" {
  name = "${var.cluster_name}-additional-security-group"
  description = "${var.cluster_name}-additional-security-group"
  vpc_id = var.vpc_id

  tags = merge(var.tags, tomap({
    Name = format("%s-%s-additional-security-group", var.prefix, var.cluster_name),
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