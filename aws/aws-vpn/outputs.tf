output "VPC" {
    value = "${aws_vpc.vpc.id}"
}
output "Private subnets" {
    value = "${join(",", aws_subnet.private_subnet.*.id)}"
}
output "Internet gateway" {
    value = "${aws_internet_gateway.vpc-igw.id}"
}
output "Customer gateway" {
    value = "${aws_customer_gateway.vpc-cgw.id}"
}
output "VPN gateway" {
    value = "${aws_vpn_gateway.vpc-vgw.id}"
}
output "VPN gateway config" {
    value = "${aws_vpn_connection.vpc-vpn.customer_gateway_configuration}"
}