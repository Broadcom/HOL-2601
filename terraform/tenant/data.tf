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

# output "namespace_class_small" {
#   value = data.kubernetes_resource.supervisor_namespace_class_config
# }
