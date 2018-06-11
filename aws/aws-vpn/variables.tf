provider "aws" {
  region= "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}
variable "region" {
    description = "The aws region"
}
variable "access_key" {
    description = "The aws access_key"
}
variable "secret_key" {
    description = "The aws secret_key"
}
variable "vpn_bgp_asn" {
    description = "BPG Autonomous System Number (ASN) of the customer gateway for a dynamically routed VPN connection."
}
variable "vpn_ip_address" {
    description = "Internet-routable IP address of the customer gateway's external interface."
}
variable "vpn_dest_cidr_block" {
    description = "Internal network IP range to advertise over the VPN connection to the VPC."
}
variable "name" {
    description = "The name of the VPC."
}
variable "cidr_block" {
    description = "The CIDR block for the VPC."
}
variable "zones" {
    description = "List of availability zones to use."
}
variable "public_subnets" {
    description = "List of CIDR blocks to use as public subnets; instances launced will be assigned a public IP address."
    default = ""
}
variable "private_subnets" {
    description = "List of CIDR blocks to use as private subnets; instances launced will NOT be assigned a public IP address."
    default = ""
}
variable "enable_dns_hostnames" {
    description = "Enable DNS hostnames in the VPC (default false)."
    default = false
}
variable "enable_dns_support" {
    description = "Enable DNS support in the VPC (default true)."
    default = true
}
variable "key_name" {
    description = "keypair name"
}
variable "public_key" {
    description = "The public key content"
}
variable "aws_ami" {
    description = "The aws ami."
}
variable "aws_instance_type" {
    description = "The aws instance type."
}