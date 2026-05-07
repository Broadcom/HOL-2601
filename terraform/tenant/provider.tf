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
            version = "~> 2.0.0"
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
    gitlab_token = trimspace(file(var.gitlab_token_file_path))
}
locals {
#   password = sensitive(trimspace(file(var.password_file_path)))
    password = trimspace(file(var.password_file_path))
}
provider "vra" {
    alias = "hol-all-apps"
    refresh_token = local.token.refresh_token
    url          = format("https://%s", var.vra_url)
    insecure     = var.vra_insecure
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

data "vcfa_kubeconfig" "tenant_kubeconfig" {}

provider "kubernetes" {
    host                   = data.vcfa_kubeconfig.tenant_kubeconfig.host
    insecure               = data.vcfa_kubeconfig.tenant_kubeconfig.insecure_skip_tls_verify
    token                  = data.vcfa_kubeconfig.tenant_kubeconfig.token
}