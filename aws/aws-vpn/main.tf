resource "aws_vpc" "vpc" {
    cidr_block = "${var.cidr_block}"
    enable_dns_support = "${var.enable_dns_support}"
    enable_dns_hostnames = "${var.enable_dns_hostnames}"
    tags {
        Name = "${var.name}-vpc"
    }
}
 
resource "aws_subnet" "private_subnet" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${element(split(",", var.private_subnets), count.index)}"
    availability_zone = "${element(split(",", var.zones), count.index)}"
    count = "${length(compact(split(",", var.private_subnets)))}"
    tags {
        Name = "${format("%s-private-%d", var.name, count.index + 1)}"
    }
}
 
resource "aws_internet_gateway" "vpc-igw" {
    vpc_id = "${aws_vpc.vpc.id}"
    tags {
        Name = "${var.name}-igw"
    }
}
 
resource "aws_vpn_gateway" "vpc-vgw" {
    vpc_id = "${aws_vpc.vpc.id}"
    tags {
        Name = "${var.name}-vgw"
    }
}
 
resource "aws_route" "vgw-route" {
    route_table_id = "${aws_vpc.vpc.main_route_table_id}"
    destination_cidr_block = "${var.vpn_dest_cidr_block}"
    gateway_id = "${aws_vpn_gateway.vpc-vgw.id}"
}
 
resource "aws_customer_gateway" "vpc-cgw" {
    bgp_asn = "${var.vpn_bgp_asn}"
    ip_address = "${var.vpn_ip_address}"
    type = "ipsec.1"
    tags {
        Name = "${var.name}-cgw"
    }
}
 
resource "aws_vpn_connection" "vpc-vpn" {
    vpn_gateway_id = "${aws_vpn_gateway.vpc-vgw.id}"
    customer_gateway_id = "${aws_customer_gateway.vpc-cgw.id}"
    type = "ipsec.1"
    static_routes_only = true
    tags {
        Name = "${var.name}-vpn"
    }
}
 
resource "aws_vpn_gateway_route_propagation" "vpnroute" {
  vpn_gateway_id = "${aws_vpn_gateway.vpc-vgw.id}"
  route_table_id = "${aws_vpc.vpc.main_route_table_id}"
}
 
resource "aws_key_pair" "vm-key" {
  key_name   = "${var.key_name}"
  public_key = "${var.public_key}"
}
 
resource "aws_security_group" "vm-sg" {
  name   = "vm-security-group"
  vpc_id = "${aws_vpc.vpc.id}"
 
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
}
 
resource "aws_instance" "vm-aws" {
  ami           = "${var.aws_ami}"
  instance_type = "${var.aws_instance_type}"
  subnet_id     = "${aws_subnet.private_subnet.id}"
  key_name      = "${aws_key_pair.vm-key.key_name}"
 
  associate_public_ip_address = false
 
  vpc_security_group_ids = [
    "${aws_security_group.vm-sg.id}"
  ]
 
  tags {
    Name = "aws-vm-test"
  }
}