resource "aws_vpc" "main_vpc_r" {
  cidr_block = var.vpc_cidr
  tags       = merge(var.tags, { Name = "${var.env}-vpc" })
}

resource "aws_subnet" "public_subnets_r" {
  vpc_id            = aws_vpc.main_vpc_r.id
  for_each          = var.public_subnets
  cidr_block        = each.value["cidr_block"]
  availability_zone = each.value["availability_zone"]
  tags = merge(var.tags,
    { Name = "${var.env}-${each.value["name"]}" }
  )
}

resource "aws_subnet" "private_subnets_r" {
  vpc_id            = aws_vpc.main_vpc_r.id
  for_each          = var.private_subnets
  cidr_block        = each.value["cidr_block"]
  availability_zone = each.value["availability_zone"]
  tags = merge(var.tags,
    { Name = "${var.env}-${each.value["name"]}" }
  )
}

resource "aws_route_table" "public_route_table_r" {
  vpc_id = aws_vpc.main_vpc_r.id
  for_each = var.public_subnets
  tags = merge(var.tags,
    { Name = "${var.env}-${each.value["name"]}" }
  )

}

resource "aws_route_table" "private_route_table_r" {
  vpc_id = aws_vpc.main_vpc_r.id
  for_each = var.private_subnets
  tags = merge(var.tags,
    { Name = "${var.env}-${each.value["name"]}" }
  )

}
