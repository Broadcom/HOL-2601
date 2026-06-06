terraform {
    # backend "local" {
    #     path = "/vpodrouter/2026-labs/2601/terraform/terraform.tfstate"
    # }
    required_providers {
        vcfa = {
            source = "vmware/vcfa"
            version = "~> 1.0.0"
        }
        vra = {
            source = "vmware/vra"
            version = "~> 0.13"
        }
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = "3.1.0"
        }
        vcf = {
            source = "vmware/vcf"
            version = "~> 0.17.1"
        }
        vsphere = {
            source = "vmware/vsphere"
            version = "~> 2.0.0"
        }
        nsxt = {
            source = "vmware/nsxt"
            version = "~> 3.11.1"
        }
        null = {
            source  = "hashicorp/null"
            version = "~> 3.2.4"
        }
        external = {
            source  = "hashicorp/external"
            version = "~> 2.3.5"
        }
    }
}


locals {
#   password = sensitive(trimspace(file(var.password_file_path)))
    password = trimspace(file(var.password_file_path))
}

provider "vcfa" {
    url                     = format("https://%s", var.vcfa_url)
    org                     = var.vcfa_org
    user                    = var.vcfa_username
    password                = local.password
    auth_type               = "integrated"
    allow_unverified_ssl    = var.vcfa_insecure
    logging                 = true
    logging_file            = var.vcfa_log_file
}
provider "vsphere" {
  user           = var.wld_vcenter_username
  password       = local.password
  vsphere_server = var.wld_vcenter_url

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


provider "external" {

}