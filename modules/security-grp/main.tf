# ============================================================
# Security Group Module
# Ingress rules are driven entirely by the caller — the module
# itself imposes no hard-coded ports, keeping it reusable.
# ============================================================

resource "aws_security_group" "this" {
  name        = var.sg_name
  description = "Security group: ${var.sg_name}"
  vpc_id      = var.vpc_id

  # Dynamic ingress — rules are supplied via var.ingress_rules
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = var.sg_name
  }
}
