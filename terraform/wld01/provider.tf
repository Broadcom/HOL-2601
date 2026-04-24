terraform {
    required_providers {

        kubernetes = {
            source = "hashicorp/kubernetes"
            version = "~> 2.0.0"
        }
        vcf = {
            source = "vmware/vcf"
            version = "0.17.1"
        }
        vsphere = {
            source = "vmware/vsphere"
            version = "~> 2.0.0"
        }
        
        nsxt = {
            source = "vmware/nsxt"
            version = "~> 3.11.1"
        }
    }
}
locals {
  password = sensitive(trimspace(file(var.password_file_path)))
}

provider "vsphere" {
  user           = var.vsphere_username
  password       = local.password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

provider "nsxt" {
  host           = var.nsx_wld01_manager_url
  username       = var.nsx_wld01_manager_username
  password       = local.password
  allow_unverified_ssl = true
  max_retries    = 4
}