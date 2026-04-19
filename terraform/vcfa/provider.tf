terraform {
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
            version = "~> 2.0.0"
        }
        vcf = {
            source = "vmware/vcf"
            version = "0.17.1"
        }
    }
}
locals {
  password = sensitive(trimspace(file(var.password_file_path)))
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