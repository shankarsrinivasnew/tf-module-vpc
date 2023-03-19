resource "aws_vpc" "main_vpc_r" {
    cidr_block = var.vpc_cidr
    tags = {
        Name = "${var.env}-vpc"
    }
}