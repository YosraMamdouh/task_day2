variable "vpc_cidr" {
  type        = string
  tags={
    Name = "vpc-${var.env}"
  }
}
