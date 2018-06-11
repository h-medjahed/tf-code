variable "client_id" {
  description = "Access key for Azure"
}
variable "client_secret" {
  description = "Secret Key for Azure"
}
variable "subscription_id" {
  description = "Subscription ID for Azure"
}
variable "tenant_id" {
  description = "Tenant ID; from EndPoint in classic panel .."
}
provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}
variable "region" {
  description = "The default Azure region for the resource provisioning"
}
variable "resource_group_name" {
  description = "Resource group name that will contain various resources"
}
variable "cidr_block" {
  description = "CIDR block for Virtual Network"
}
variable "subnet_cidr_block" {
  description = "CIDR block for Subnet within a Virtual Network"
}
variable "subnet_name" {
  description = "Name for Subnet within a Virtual Network"
}
variable "vm_username" {
  description = "Enter admin username to SSH into Linux VM"
}
variable "public_key" {
    description = "The public key content"
}
variable "vnet_name" {
    description = "The virtual network name"
}