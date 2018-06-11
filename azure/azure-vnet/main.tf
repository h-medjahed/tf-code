resource "azurerm_resource_group" "rgroup" {
    name     = "${var.resource_group_name}"
    location = "${var.region}"

    tags {
        environment = "Terraform Demo"
    }
}

resource "azurerm_virtual_network" "aznetwork" {
    name                = "${var.vnet_name}"
    address_space       = ["${var.cidr_block}"]
    location            = "${var.region}"
    resource_group_name = "${azurerm_resource_group.rgroup.name}"

    tags {
        environment = "Terraform Demo"
    }
}

resource "azurerm_subnet" "azsubnet" {
    name                 = "${var.subnet_name}"
    resource_group_name  = "${azurerm_resource_group.rgroup.name}"
    virtual_network_name = "${azurerm_virtual_network.aznetwork.name}"
    address_prefix       = "${var.subnet_cidr_block}"
}

resource "azurerm_public_ip" "azpublicip" {
    name                         = "myPublicIP"
    location                     = "${var.region}"
    resource_group_name          = "${azurerm_resource_group.rgroup.name}"
    public_ip_address_allocation = "dynamic"

    tags {
        environment = "Terraform Demo"
    }
}

resource "azurerm_network_security_group" "azpublicipnsg" {
    name                = "myNetworkSecurityGroup"
    location            = "${var.region}"
    resource_group_name = "${azurerm_resource_group.rgroup.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "vpntunnel"
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "UDP"
        source_port_range          = "*"
        destination_port_range     = "4500"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "vpntunnel1"
        priority                   = 201
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "UDP"
        source_port_range          = "*"
        destination_port_range     = "500"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        environment = "Terraform Demo"
    }
}

resource "azurerm_network_interface" "aznic" {
    name                = "myNIC"
    location            = "${var.region}"
    resource_group_name = "${azurerm_resource_group.rgroup.name}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.azsubnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.azpublicip.id}"
    }

    tags {
        environment = "Terraform Demo"
    }
}

resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.rgroup.name}"
    }

    byte_length = 8
}

resource "azurerm_storage_account" "azstorageaccount" {
    name                = "diag${random_id.randomId.hex}"
    resource_group_name = "${azurerm_resource_group.rgroup.name}"
    location            = "${var.region}"
    account_replication_type = "LRS"
    account_tier = "Standard"

    tags {
        environment = "Terraform Demo"
    }
}


resource "azurerm_virtual_machine" "azvm" {
    name                  = "myVM"
    location              = "${var.region}"
    resource_group_name   = "${azurerm_resource_group.rgroup.name}"
    network_interface_ids = ["${azurerm_network_interface.aznic.id}"]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "myvm"
        admin_username = "${var.vm_username}"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = "${var.public_key}"
        }
    }

    boot_diagnostics {
        enabled     = "true"
        storage_uri = "${azurerm_storage_account.azstorageaccount.primary_blob_endpoint}"
    }

    tags {
        environment = "Terraform Demo"
    }
}