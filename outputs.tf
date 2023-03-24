output "myoutsub_public" {
    value = aws_subnet.public_subnets_r
}

output "myoutsub_private" {
    value = aws_subnet.private_subnets_r
}

output "myoutvpcid" {
    value = aws_vpc.main_vpc_r.id
}