resource "kubernetes_manifest" "project" {
  manifest = {
    "apiVersion" = "project.cci.vmware.com/v1alpha2"
    "kind"       = "Project"
    "metadata" = {
      "name" = var.project_name
    }
    "spec" = {
      "description" = "Project ${var.project_name}"
    }
  }
}

data "kubernetes_resources" "project_roles" {
  api_version = "authorization.cci.vmware.com/v1alpha1"
  kind        = "ProjectRole"
}


output "project_roles" {
  value = data.kubernetes_resources.project_roles
}

resource "null_resource" "vcfa_bearer_token" {

  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    quiet = false
    
    command = <<EOT
set -euo pipefail

response=$(curl -sk --fail-with-body -X POST \
  "${format("https://%s", var.vra_url)}/oauth/provider/token" \
  -H "Accept: application/json" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "Content-Type: application/json" \
  --data-urlencode "grant_type=refresh_token" \
  --data-urlencode "refresh_token=${local.token.refresh_token}")
  
  access_token=$(echo $response | jq -r '.access_token // empty')
  
  echo "$access_token" > ${path.cwd}/scripts/bearer.txt
  EOT
  }
}

resource "null_resource" "vcfa_access_control_group" {
    provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    quiet = false
    
    command = <<EOT
set -euo pipefail

response=$(curl -sk --fail-with-body -X GET \
  "${format("https://%s", var.vra_url)}/cloudapi/1.0.0/groups" \
  -H "Accept: application/json" \
  -H "Authorization: bearer ${local.bearer_token}" \
  -H "Content-Type: application/json")
  
echo "$response"
  EOT

  }
}

# resource "kubernetes_manifest" "project_role_bindings" {
#   count = length(var.users)
#   depends_on = [
#     kubernetes_manifest.project
#   ]

#   manifest = {
#     "apiVersion" = "authorization.cci.vmware.com/v1alpha1"
#     "kind"       = "ProjectRoleBinding"
#     "metadata" = {
#       "name"      = "cci:user:${var.users[count.index].name}"
#       "namespace" = var.project_name
#     }
#     "roleRef" = {
#       "apiGroup" = "authorization.cci.vmware.com"
#       "kind"     = "ProjectRole"
#       "name"     = var.users[count.index].role
#     }
#     "subjects" = [
#       {
#         "kind" = "User"
#         "name" = var.users[count.index].name
#       }
#     ]
#   }
# }

# resource "vcfa_supervisor_namespace" "project_namespace" {
#   depends_on = [
#     kubernetes_manifest.project
#   ]

#   name_prefix  = var.namespace_name
#   project_name = var.project_name
#   class_name   = var.namespace_class
#   description  = var.namespace_description
#   region_name  = var.namespace_region
#   vpc_name     = var.namespace_vpc


#   storage_classes_initial_class_config_overrides {
#     limit = var.namespace_class_storage_class_limit
#     name  = var.namespace_storage_class_name
#   }

#   zones_initial_class_config_overrides {
#     cpu_limit          = var.namespace_class_cpu_limit
#     cpu_reservation    = var.namespace_class_cpu_reservation
#     memory_limit       = var.namespace_class_memory_limit
#     memory_reservation = var.namespace_class_memory_reservation
#     name               = var.namespace_zone
#   }
# }
