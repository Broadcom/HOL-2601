data "terraform_remote_state" "vcfa" {
    backend = "local"
    config = {
        path = "../provider/terraform.tfstate"
    }
}
data "local_file" "org_api_token_file" {
  filename = data.terraform_remote_state.vcfa.outputs.org_api_token_file.file_name
}

locals {
  token = jsondecode(data.local_file.org_api_token_file.content)
}