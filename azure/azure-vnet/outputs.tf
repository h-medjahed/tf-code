output "Public Ip" {
    value = "${azurerm_public_ip.azpublicip.ip_address}"
}