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
  vpc_id   = aws_vpc.main_vpc_r.id
  for_each = var.public_subnets
  tags = merge(var.tags,
    { Name = "${var.env}-${each.value["name"]}" }
  )

}

resource "aws_route_table" "private_route_table_r" {
  vpc_id   = aws_vpc.main_vpc_r.id
  for_each = var.private_subnets
  tags = merge(var.tags,
    { Name = "${var.env}-${each.value["name"]}" }
  )

}

resource "aws_route_table_association" "public_association" {
  for_each = var.public_subnets
  # subnet_id      = aws_subnet.public_subnets_r.each.values["name"].id
  subnet_id      = lookup(lookup(aws_subnet.public_subnets_r, each.value["name"], null), "id", null)
  route_table_id = aws_route_table.public_route_table_r[each.values["name"]].id
}

resource "aws_route_table_association" "private_association" {
  for_each = var.private_subnets
  # subnet_id      = aws_subnet.private_subnets_r.each.values["name"].id
  subnet_id      = lookup(lookup(aws_subnet.private_subnets_r, each.value["name"], null), "id", null)
  route_table_id = aws_route_table.private_route_table_r[each.values["name"]].id
}
