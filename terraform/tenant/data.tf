data "terraform_remote_state" "vcfa" {
    backend = "local"
    config = {
        path = "${path.cwd}/provider/terraform.tfstate"
    }
}
data "local_file" "org_api_token_file" {
  filename = data.terraform_remote_state.vcfa.outputs.org_api_token_file
}

locals {
  token = jsondecode(data.local_file.org_api_token_file.content)
}

output "vra_org_api_token" {
  value = local.token
}
