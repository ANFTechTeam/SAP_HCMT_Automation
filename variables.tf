variable "prefix" {
    description     = "prefix for SAP resources"
    default         = "saphana"
}

variable "username" {
    description     = "SUSE Admin User"
    default         = "seanluce"
}

variable "region" {
    description     = "azure region where resources should be created"
    default         = "East US 2"
}

variable "rg" {
    description     = "existing resource group"
    default         = "sluce.rg"
}
    
variable "vnet" {
    description     = "existing VNET"
    default         = "sluce.rg_vnet"
}  

variable "vm_subnet" {
    description     = "name of existing VM subnet"
    default         = "PrimarySubnet"
}

variable "subnet" {
    description     = "desired/existing name of ANF subnet"
    default         = "ANFSubnet"
}

variable "address_range" {
    description     = "CIDR range for ANF subnet"
    default         = "172.18.20.0/24"
}  

variable "naa" {
    description     = "name of NetApp Account to be created for ANF"
    default         = "sluce-SAP-HANA"
}

variable "datapool" {
    description     = "name of HANA data capacity pool to be created"
    default         = "HANADataCapacityPool"
}

variable "datapool_size" {
    description     = "size of HANA data capacity pool in TiB"
    default         = "4"
}

variable "dataservice_level" {
    description     = "HANA data capacity pool service level: Standard, Premium or Ultra"
    default         = "Standard"
}

variable "logpool" {
    description     = "name of HANA log capacity pool to be created"
    default         = "HANALogCapacityPool"
}

variable "logpool_size" {
    description     = "size of HANA log capacity pool in TiB"
    default         = "4"
}

variable "logservice_level" {
    description     = "HANA log capacity pool service level: Standard, Premium or Ultra"
    default         = "Standard"
}

variable "hana_data_volume" {
    description     = "name of volume to be created"
    default         = "hanadata"
}

variable "hana_data_volume_path" {
    description     = "volume mount path, no underscores for SMB"
    default         = "hanadata" 
}

variable "hana_data_quota" {
    description     = "desired volume quota in GiB"
    default         = "100"
}

variable "hana_log_volume" {
    description     = "name of volume to be created"
    default         = "hanalog"
}

variable "hana_log_volume_path" {
    description     = "volume mount path, no underscores for SMB"
    default         = "hanalog" 
}

variable "hana_log_quota" {
    description     = "desired volume quota in GiB"
    default         = "100"
}

variable "standard_tags" {
    description     = "tags to be applied to all resources"
    default         = {
        creator     = "luces"
        owner       = "luces"
        keepalive   = "yes"
    }
}