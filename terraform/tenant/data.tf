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
data "kubernetes_resource" "namespace_class_small" {

  api_version = "infrastructure.cci.vmware.com/v1alpha2"
  kind        = "SupervisorNamespaceClassConfig"

  metadata {
    name = "small"
  }
}

data "kubernetes_resource" "namespace_class_medium" {

  api_version = "infrastructure.cci.vmware.com/v1alpha2"
  kind        = "SupervisorNamespaceClassConfig"

  metadata {
    name = "medium"
  }
}

data "kubernetes_resource" "namespace_class_large" {

  api_version = "infrastructure.cci.vmware.com/v1alpha2"
  kind        = "SupervisorNamespaceClassConfig"

  metadata {
    name = "large"
  }
}

# data "external" "vcfa_org_token" {
#   program = [
#     "/bin/bash",
#     <<-EOT
# set -euo pipefail

# response=$(curl -sk -X POST \
#   "${format("https://%s", var.vra_url)}/oauth/provider/token" \
#   -H "Accept: application/json" \
#   -H "Content-Type: application/x-www-form-urlencoded" \
#   --data-urlencode "grant_type=refresh_token" \
#   --data-urlencode "refresh_token=${local.token.refresh_token}")

# access_token=$(echo "$response" | jq -r '.access_token // empty')

# if [ -z "$access_token" ]; then
#   echo "$response" >&2
#   exit 1
# fi

# jq -n --arg access_token "$access_token" '{access_token:$access_token}'
# EOT
#   ]
# }

data "external" "vcfa_org_token" {
  program = [
    "/bin/bash",
    "${path.cwd}/scripts/token.sh"
  ]

  query = {
    url = var.vra_url
    token = local.token.refresh_token
  }
}

output "org_bearer_token" {
  value = data.external.vcfa_org_token.result.access_token
}
# output "namespace_class_small" {
#   value = data.kubernetes_resource.supervisor_namespace_class_config
# }
