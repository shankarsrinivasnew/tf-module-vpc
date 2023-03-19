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
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_r.id
  }

}

resource "aws_route_table" "private_route_table_r" {
  vpc_id   = aws_vpc.main_vpc_r.id
  for_each = var.private_subnets
  tags = merge(var.tags,
    { Name = "${var.env}-${each.value["name"]}" }
  )
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateways["public-${split("-", each.value["name"])[1]}"].id # based on variables from public subnets . nat created in public subnets
  }

}

resource "aws_route_table_association" "public_association" {
  for_each = var.public_subnets
  # subnet_id      = aws_subnet.public_subnets_r[each.values["name"]].id
  subnet_id      = lookup(lookup(aws_subnet.public_subnets_r, each.value["name"], null), "id", null)
  route_table_id = aws_route_table.public_route_table_r[each.value["name"]].id
}

resource "aws_route_table_association" "private_association" {
  for_each = var.private_subnets
  # subnet_id      = aws_subnet.private_subnets_r[each.values["name"]].id
  subnet_id      = lookup(lookup(aws_subnet.private_subnets_r, each.value["name"], null), "id", null)
  route_table_id = aws_route_table.private_route_table_r[each.value["name"]].id
}


resource "aws_internet_gateway" "igw_r" {
  vpc_id = aws_vpc.main_vpc_r.id
  tags   = merge(var.tags, { Name = "${var.env}-vpc" })
}

resource "aws_eip" "eip" {
  for_each = var.public_subnets
  vpc      = true
}

resource "aws_nat_gateway" "nat_r" {
  for_each      = var.public_subnets
  allocation_id = aws_eip.eip[each.values["name"]].id
  subnet_id     = lookup(lookup(aws_subnet.public_subnets_r, each.value["name"], null), "id", null)

  tags = merge(var.tags,
    { Name = "${var.env}-${each.value["name"]}" }
  )

}
