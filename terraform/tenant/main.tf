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

resource "vcfa_supervisor_namespace" "supervisor_namespace" {
  depends_on = [
    kubernetes_manifest.supervisor_namespace_class_config
  ]

  name_prefix  = var.namespace_name
  project_name = var.project_name
  class_name   = var.namespace_class
  description  = ""
  region_name  = var.namespace_region
  vpc_name     = var.namespace_vpc

  storage_classes_initial_class_config_overrides {
    limit = var.namespace_class_storage_class_limit
    name  = var.namespace_storage_class_name
  }

  zones_initial_class_config_overrides {
    cpu_limit          = var.namespace_class_cpu_limit
    cpu_reservation    = var.namespace_class_cpu_reservation
    memory_limit       = var.namespace_class_memory_limit
    memory_reservation = var.namespace_class_memory_reservation
    name               = var.namespace_zone
  }
}
