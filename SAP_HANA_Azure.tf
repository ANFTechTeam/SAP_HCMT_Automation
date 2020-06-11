# https://www.terraform.io/docs/providers/index.html
provider "azurerm" {
    version = "~>2.0"
    features {}
    skip_provider_registration = true
}

data "template_file" "cloudconfig" {
  template = file("./cloud-init.tpl")
  vars = {
    data_mount_ip_address = azurerm_netapp_volume.netapp_volume_hanadata.mount_ip_addresses[0]
    log_mount_ip_address = azurerm_netapp_volume.netapp_volume_hanalog.mount_ip_addresses[0]
  }
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.cloudconfig.rendered
  }
}


# reference VM subnet (primary subnet)
data "azurerm_subnet" "primary" {
  name = var.vm_subnet
  virtual_network_name = var.vnet
  resource_group_name = var.rg
}

# reference existing ANF delegated subnet
data "azurerm_subnet" "anf" {
  name = var.subnet
  virtual_network_name = var.vnet
  resource_group_name = var.rg
}

# create public IP for vm
resource "azurerm_public_ip" "public_ip" {
  name                = "${var.prefix}-publicip"
  resource_group_name   = var.rg
  location              = var.region
  allocation_method   = "Dynamic"
}

# create VM network interface
resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = var.region
  resource_group_name = var.rg
  ip_configuration {
    name                          = "sap_hana_ip"
    subnet_id                     = data.azurerm_subnet.primary.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
} 

# create SLES VM
resource "azurerm_linux_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  resource_group_name   = var.rg
  location              = var.region
  size               = "Standard_E32as_v4"
  admin_username     = var.username
  network_interface_ids = [
    azurerm_network_interface.main.id,
    ]
  source_image_reference {
    publisher = "suse"
    offer     = "sles-15-sp1-basic"
    sku       = "gen2-cloud-init-preview"
    version   = "latest"
  }
  os_disk {
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  admin_ssh_key {
      username = var.username
      public_key = file("~/.ssh/id_rsa.pub")
    }
  custom_data = data.template_cloudinit_config.config.rendered
  tags = {
    environment = ""
  }
}

# https://www.terraform.io/docs/providers/azurerm/r/netapp_account.html
resource "azurerm_netapp_account" "netapp_account" {
    name                        = var.naa
    location                    = var.region
    resource_group_name         = var.rg
    tags                        = var.standard_tags  
}

# https://www.terraform.io/docs/providers/azurerm/r/netapp_pool.html
resource "azurerm_netapp_pool" "hanadata_pool" {
    name                        = var.datapool
    account_name                = azurerm_netapp_account.netapp_account.name
    location                    = var.region
    resource_group_name         = var.rg
    service_level               = var.dataservice_level
    size_in_tb                  = var.datapool_size
    tags                        = var.standard_tags
}

# https://www.terraform.io/docs/providers/azurerm/r/netapp_pool.html
resource "azurerm_netapp_pool" "hanalog_pool" {
    name                        = var.logpool
    account_name                = azurerm_netapp_account.netapp_account.name
    location                    = var.region
    resource_group_name         = var.rg
    service_level               = var.logservice_level
    size_in_tb                  = var.logpool_size
    tags                        = var.standard_tags
}

/*
# https://www.terraform.io/docs/providers/azurerm/r/subnet.html
resource "azurerm_subnet" "anf_subnet" {
  name                 = var.subnet
  resource_group_name  = var.rg
  virtual_network_name = var.vnet
  address_prefixes       = [var.address_range]

  delegation {
    name = "netapp"
    service_delegation {
      name    = "Microsoft.Netapp/volumes"
      actions = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}
*/

# https://www.terraform.io/docs/providers/azurerm/r/netapp_volume.html
resource "azurerm_netapp_volume" "netapp_volume_hanadata" {
    lifecycle {
        prevent_destroy         = false
    }
    name                        = var.hana_data_volume
    location                    = var.region
    resource_group_name         = var.rg
    account_name                = azurerm_netapp_account.netapp_account.name
    pool_name                   = azurerm_netapp_pool.hanadata_pool.name
    volume_path                 = var.hana_data_volume_path
    service_level               = var.dataservice_level
    subnet_id                   = data.azurerm_subnet.anf.id
    protocols                   = ["NFSv4.1"]
    storage_quota_in_gb         = var.hana_data_quota
    export_policy_rule {
        rule_index = "1"
        allowed_clients = ["0.0.0.0/0"]
        protocols_enabled = ["NFSv4.1"]
        unix_read_write = true
    }
    #tags                        = var.standard_tags
}

# https://www.terraform.io/docs/providers/azurerm/r/netapp_volume.html
resource "azurerm_netapp_volume" "netapp_volume_hanalog" {
    lifecycle {
        prevent_destroy         = false
    }
    name                        = var.hana_log_volume
    location                    = var.region
    resource_group_name         = var.rg
    account_name                = azurerm_netapp_account.netapp_account.name
    pool_name                   = azurerm_netapp_pool.hanalog_pool.name
    volume_path                 = var.hana_log_volume_path
    service_level               = var.logservice_level
    subnet_id                   = data.azurerm_subnet.anf.id
    protocols                   = ["NFSv4.1"]
    storage_quota_in_gb         = var.hana_log_quota
    export_policy_rule {
        rule_index = "1"
        allowed_clients = ["0.0.0.0/0"]
        protocols_enabled = ["NFSv4.1"]
        unix_read_write = true
    }
    #tags                        = var.standard_tags
    #depends_on                  = [azurerm_netapp_volume.netapp_volume_hanadata]
}

output "HANA_Data_Mount_IP_Address" {
  value = azurerm_netapp_volume.netapp_volume_hanadata.mount_ip_addresses
}

output "HANA_Log_Mount_IP_Address" {
  value = azurerm_netapp_volume.netapp_volume_hanalog.mount_ip_addresses
}


output "SLES_VM_Private_IP_Address" {
  value = azurerm_network_interface.main.private_ip_address
}

output "SLES_Public_IP_address" {
  value = azurerm_linux_virtual_machine.main.public_ip_address
}
