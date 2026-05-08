resource "kubernetes_manifest" "project" {
  manifest = {
    "apiVersion" = "project.cci.vmware.com/v1alpha2"
    "kind"       = "Project"
    "metadata" = {
      "name" = var.project_name
    }
    "spec" = {
      "description" = "Project [${var.project_name}]"
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
