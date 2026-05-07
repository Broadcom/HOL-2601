terraform {
    # backend "local" {
    #     path = "/vpodrouter/2026-labs/2601/terraform/terraform.tfstate"
    # }
    required_providers {

        vra = {
            source = "vmware/vra"
            version = "~> 0.13"
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
    gitlab_token = sensitive(trimspace(file(var.gitlab_token_file_path)))
}

provider "vra" {
    alias = "hol-all-apps"
    refresh_token = local.token.refresh_token
    url          = format("https://%s", var.vra_url)
    insecure     = var.vra_insecure
}
