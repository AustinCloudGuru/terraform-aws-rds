#-----------------------------------
# Create the Security Group
#-----------------------------------
resource "aws_security_group" "this" {
  name        = var.name
  description = join(" ", ["Security Group for", var.name])
  vpc_id      = var.vpc_id
  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "aws_security_group_rule" "this_ingress" {
  for_each          = var.security_group_ingress[var.engine]
  security_group_id = aws_security_group.this.id
  type              = "ingress"
  description       = lookup(each.value, "description", null)
  from_port         = lookup(each.value, "from_port", null)
  protocol          = lookup(each.value, "protocol", null)
  to_port           = lookup(each.value, "to_port", null)
  self              = lookup(each.value, "self", null) == false ? null : each.value.self
  cidr_blocks       = lookup(each.value, "cidr_blocks", null)
}

resource "aws_security_group_rule" "this_egress" {
  for_each          = var.security_group_egress
  security_group_id = aws_security_group.this.id
  type              = "egress"
  from_port         = lookup(each.value, "from_port", null)
  protocol          = lookup(each.value, "protocol", null)
  to_port           = lookup(each.value, "to_port", null)
  self              = lookup(each.value, "self", null) == false ? null : each.value.self
  cidr_blocks       = lookup(each.value, "cidr_blocks", null)
}
