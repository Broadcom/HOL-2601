
# RESOURCES

resource "vcfa_api_token" "system_api_token" {
  name             = "system_token"
  file_name        = "${path.cwd}/system_token.json"
  allow_token_file = true
}

locals {
  system_token_file = jsondecode(data.local_file.system_token_file.content)
}
output "api_token" {
  value = local.system_token_file.refresh_token
}


resource "vcfa_region" "region" {
  name                 = var.region_name
  nsx_manager_id       = data.vcfa_nsx_manager.nsx.id
  supervisor_ids       = [data.vcfa_supervisor.sv.id]
  storage_policy_names = var.region_storage_policy_names
}

resource "vcfa_org" "tenant_org" {
    name                = var.vcfa_tenant_org
    display_name        = var.vcfa_tenant_org
    description         = "Hands-on Labs Organization"
    is_enabled          = true
    is_classic_tenant   = false
}

resource "vcfa_org_settings" "org_settings" {
  org_id                           = vcfa_org.tenant_org.id
  can_create_subscribed_libraries  = true
  quarantine_content_library_items = false
}

resource "vcfa_org_region_quota" "region_quota" {
  org_id         = vcfa_org.tenant_org.id
  region_id      = vcfa_region.region.id
  supervisor_ids = [data.vcfa_supervisor.sv.id]
  zone_resource_allocations {
    region_zone_id         = data.vcfa_region_zone.zone.id
    cpu_limit_mhz          = tostring(tonumber(data.external.cluster_capacity.result.cpu_capacity) * 0.5)
    cpu_reservation_mhz    = var.region_quota_cpu_reservation_mhz
    memory_limit_mib       = tostring(floor((tonumber(data.external.cluster_capacity.result.mem_capacity) * 0.953674) * 0.5))
    memory_reservation_mib = var.region_quota_mem_reservation_mb
  }
  region_vm_class_ids = [
    data.vcfa_region_vm_class.vm_class1.id,
    data.vcfa_region_vm_class.vm_class2.id,
    data.vcfa_region_vm_class.vm_class3.id,
    data.vcfa_region_vm_class.vm_class4.id,
  ]
  region_storage_policy {
    region_storage_policy_id = data.vcfa_region_storage_policy.region-sc.id
    storage_limit_mib        = tostring(floor((tonumber(data.external.cluster_capacity.result.vsan_capacity) * 0.953674) * 0.25))
  }
}

# Create VCFA Network Logs Label
resource "vcfa_org_networking" "network" {
  org_id   = vcfa_org.tenant_org.id
  log_name = lower(var.vcfa_tenant_org_log_name)
}

# Fetch VCFA Org Admin Role

# Create First User for VCFA Org
resource "vcfa_org_local_user" "user" {
  org_id   = vcfa_org.tenant_org.id
  role_ids = [data.vcfa_role.org-admin.id]
  username = var.vcfa_tenant_org_local_username
  password = local.password
}

# Create VCFA Edge Cluster QoS
resource "vcfa_edge_cluster_qos" "edge-cluster-qos" {
  edge_cluster_id = data.vcfa_edge_cluster.edge-cluster.id

  egress_committed_bandwidth_mbps  = -1
  egress_burst_size_bytes          = -1
  ingress_committed_bandwidth_mbps = -1
  ingress_burst_size_bytes         = -1
}

# Create VCFA IP Space
resource "vcfa_ip_space" "ipspace" {
  name                          = "${var.vcfa_tenant_org}-ipspace"
  description                   = "${var.vcfa_tenant_org} IP Space"
  region_id                     = vcfa_region.region.id
  external_scope                = "0.0.0.0/0"
  default_quota_max_subnet_size = var.ipspace_max_subnet_size
  default_quota_max_cidr_count  = var.ipspace_max_cidr_count
  default_quota_max_ip_count    = var.ipspace_max_ip_count
  internal_scope {
    name = "scope1"
    cidr = var.ipspace_scope_cidr1
  }
}
# Create VCFA Provider Gateway
resource "vcfa_provider_gateway" "provider-gw" {
  name             = "${var.vcfa_tenant_org}-provider-gw"
  description      = "${var.vcfa_tenant_org} Provider Gateway"
  region_id        = vcfa_region.region.id
  tier0_gateway_id = data.vcfa_tier0_gateway.t0-gw.id
  ip_space_ids     = [vcfa_ip_space.ipspace.id]
}

# Create VCFA Regional Networking
resource "vcfa_org_regional_networking" "regional-network" {
  name = "${var.vcfa_tenant_org}-regional-network"
  org_id = vcfa_org_networking.network.id
  provider_gateway_id = vcfa_provider_gateway.provider-gw.id
  region_id           = vcfa_region.region.id

  edge_cluster_id = data.vcfa_edge_cluster.edge-cluster.id
}

# Create Content Library
resource "vcfa_content_library" "provider_cl" {
  depends_on = [
    vcfa_region.region
  ]
  org_id      = data.vcfa_org.system.id
  name        = var.global_content_library_name
  description = var.global_content_library_description
  storage_class_ids = [
    data.vcfa_storage_class.sc.id
  ]
}

resource "null_resource" "tenant_ready" {
  depends_on = [ 
    vcfa_org.tenant_org, 
    vcfa_org_settings.org_settings, 
    vcfa_org_region_quota.region_quota, 
    vcfa_org_networking.network, 
    vcfa_org_local_user.user, 
    vcfa_edge_cluster_qos.edge-cluster-qos, 
    vcfa_ip_space.ipspace, 
    vcfa_provider_gateway.provider-gw, 
    vcfa_org_regional_networking.regional-network, 
    vcfa_content_library.provider_cl 
  ]
}

# resource "vcfa_rights_bundle" "orchestrator-rights" {
#   depends_on = [
#     null_resource.tenant_ready
#   ]
#   name = "${data.vcfa_rights_bundle.orch-rights.name} Custom"
#   description = "Custom rights bundle for Orchestrator"
#   publish_to_all_orgs = false
#   rights = setunion(data.vcfa_rights_bundle.orch-rights.rights, ["Integrations Orchestrator: Manage"])
#   org_ids = [
#     vcfa_org.tenant_org.id
#   ]
# }
resource "null_resource" "set_ntp" {
  depends_on = [
    null_resource.tenant_ready
  ]
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    quiet = false

    command = <<EOT
set -euo pipefail

sshpass -p "${local.password}" ssh \
 -o StrictHostKeyChecking=no \
 -o ConnectTimeout=10 \
 ${var.vcfo_orchestrator_username}@${var.vcfo_orchestrator_url} '

set -euo pipefail 
vracli ntp systemd --set 10.1.1.1
'
EOT
  }
}

resource "null_resource" "set_password_file" {
  depends_on = [ null_resource.set_ntp ]
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    quiet = false

    command = <<EOT
set -euo pipefail

sshpass -p '${local.password}' ssh \
 -o StrictHostKeyChecking=no \
 -o ConnectTimeout=10 \
 ${var.vcfo_orchestrator_username}@${var.vcfo_orchestrator_url} '
 
 set -euo pipefail
 echo ${local.password} > ${var.vcfa_fullpath_password_file}

'

EOT
  }
}

resource "null_resource" "orchestrator_config" {
  depends_on = [ null_resource.set_password_file ]

  triggers = {
    vcfo_url            = var.vcfo_orchestrator_url
    vcfo_username       = var.vcfa_username
    vcfo_password_file  = var.vcfa_username_pwd_file
    vcfa_org            = var.vcfa_tenant_org
    vcfa_password       = local.password
  }
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    quiet = false

    command = <<EOT
set -euo pipefail


sshpass -p '${local.password}' ssh \
 -o StrictHostKeyChecking=no \
 -o ConnectTimeout=10 \
 ${var.vcfo_orchestrator_username}@${var.vcfo_orchestrator_url} '

set -euo pipefail

vracli vro authentication set \
--force \
--ignore-certificate \
--provider=tm \
  --username="${var.vcfa_username}" \
  --password-file="${var.vcfa_username_pwd_file}" \
--hostname="${format("https://%s", var.vcfa_url)}" \
--tenant="${var.vcfa_tenant_org}"
'
EOT
  }
  provisioner "local-exec" {
    when = destroy
    interpreter = ["/bin/bash", "-c"]
    on_failure = continue

    command = <<EOT
set -euo pipefail

sshpass -p '${self.triggers.vcfa_password}' ssh \
 -o StrictHostKeyChecking=no \
 -o ConnectTimeout=10 \
 ${self.triggers.vcfo_username}@${self.triggers.vcfo_url} '

set -euo pipefail

vracli vro authentication unregister \
 --username=${self.triggers.vcfo_username}
 --password-file=${self.triggers.vcfo_password_file}
'
EOT
  }
}

resource "null_resource" "run_deploy_ssh" {
  depends_on = [ null_resource.orchestrator_config ]
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    quiet = false

    command = <<EOT
set -euo pipefail

sshpass -p '${local.password}' ssh \
 -o StrictHostKeyChecking=no \
 -o ConnectTimeout=10 \
 ${var.vcfo_orchestrator_username}@${var.vcfo_orchestrator_url} '

set -euo pipefail
bash /opt/scripts/deploy.sh
'
EOT
  }
}

resource "null_resource" "orchestrator_ready" {
  depends_on = [ 
    null_resource.run_deploy_ssh 
  ]
}

resource "vcfa_api_token" "org_api_token" {
  depends_on = [
    null_resource.tenant_ready
  ]
  
  name             = "org_token"
  file_name        = "${path.cwd}/org_token.json"
  allow_token_file = true
}

locals {
  org_token_file = jsondecode(data.local_file.org_token_file.content)
}

output "org_api_token_file" {
  depends_on = [ data.local_file.org_token_file ]
  value = data.local_file.org_token_file.filename
}

output "org_api_token" {
  depends_on = [ data.local_file.org_token_file ]
  value = local.org_token_file
}

resource "vcfa_org_ldap" "rainpole-io" {
  depends_on = [
    null_resource.tenant_ready
  ]
  org_id                 = vcfa_org.tenant_org.id
  ldap_mode              = "CUSTOM"
  auto_trust_certificate = false # Because is_ssl = false
  custom_settings {
    server                  = var.ldap_host
    port                    = var.ldap_port
    is_ssl                  = var.ldap_ssl
    username                = var.ldap_bind_dn
    password                = local.password
    base_distinguished_name = var.ldap_search_base
    connector_type          = "OPEN_LDAP"
    user_attributes {
      object_class                = "person"
      unique_identifier           = "entryUUID"
      username                    = "cn"
      display_name                = "displayName"
      given_name                  = "givenName"
      surname                     = "sn"
      email                       = "mail"
      telephone                   = "telephoneNumber"
      group_membership_identifier = "dn"

    }
    group_attributes {
      object_class                = "groupOfNames"
      unique_identifier           = "entryUUID"
      name                        = "cn"
      membership                  = "member"
      group_membership_identifier = "dn"
    }
  }
}


# Create Content Library
resource "vcfa_content_library" "tenant_cl" {
  depends_on = [
    null_resource.tenant_ready
  ]
  org_id      = vcfa_org.tenant_org.id
  name        = var.vcfa_tenant_org_content_library_name
  description = var.vcfa_tenant_org_content_library_description
  storage_class_ids = [
    data.vcfa_storage_class.sc.id
  ]
}