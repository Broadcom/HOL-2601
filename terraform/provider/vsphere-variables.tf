variable "vsphere_username" {
  type          = string
  description   = "The vSphere username"
  default       = "administrator@wld.sso"
}

variable "vsphere_server" {
  type          = string
  description   = "The vSphere server to connect to"
  default       = "vc-wld01-a.site-a.vcf.lab"
}
variable "datacenter" {
  type          = string
  description   = "The name of the vSphere datacenter to use"
  default       = "Datacenter"
}
variable "cluster" {
  type          = string
  description   = "The name of the vSphere cluster to use"
  default       = "Cluster"
}

variable "datastore" {
  type          = string
  description   = "The name of the vSphere datastore to use"
  default       = "vsanDatastore"
}

variable "network" {
  type          = string
  description   = "The name of the vSphere network to use"
  default       = "VM Network"
}

variable "template_name" {
  type          = string
  description   = "The name of the vSphere template to use for VM creation"
  default       = "ubuntu-2204-kube-v1.27.3"
}

variable "vm_name" {
    type          = string
    description   = "The name of the vSphere VM to create"
  
}
variable "vm_hostname" {
    type          = string
    description   = "The hostname to assign to the vSphere VM"
}

variable "vm_folder" {
    type          = string
    description   = "The name of the vSphere folder to create the VM in"
}

variable "vm_cpus" {
    type          = number
    description   = "The number of CPUs to allocate to the vSphere VM"
    default       = 2
}

variable "vm_memory" {
    type          = number
    description   = "The amount of memory to allocate to the vSphere VM"
    default       = 4096
}

variable "vm_disk_size" {
    type          = number
    description   = "The size of the disk to allocate to the vSphere VM in GB"
    default       = 20
}

variable "vm_ipv4_address" {
    type          = string
    description   = "The IPv4 address to assign to the vSphere VM"
}

variable "vm_ipv4_netmask" {
    type          = number
    description   = "The IPv4 netmask to assign to the vSphere VM"
    default       = 24
}

variable "vm_ipv4_gateway" {
    type          = string
    description   = "The IPv4 gateway to assign to the vSphere VM"
}

variable "vm_ipv4_dns_servers" {
    type          = list(string)
    description   = "The IPv4 DNS servers to assign to the vSphere VM"
    default       = ["10.1.1.1"]
}

variable "vm_domain" {
    type          = string
    description   = "The domain to assign to the vSphere VM"
    default       = "site-a.vcf.lab"
}
