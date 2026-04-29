
# RESOURCES

resource "vcfa_api_token" "system_api_token" {
  name             = "system_token"
  file_name        = "${path.cwd}/system_token.json"
  allow_token_file = true
}

locals {
  token_file = jsondecode(data.local_file.token.content)
}
output "api_token" {
  value = local.token_file.refresh_token
  sensitive = true
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
    cpu_limit_mhz          = var.region_quota_cpu_limit_mhz
    cpu_reservation_mhz    = var.region_quota_cpu_reservation_mhz
    memory_limit_mib       = var.region_quota_mem_limit_mb
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
    storage_limit_mib        = var.region_quota_storage_limit_mb
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
  org_id      = data.vcfa_org.system.id
  name        = var.global_content_library_name
  description = var.global_content_library_description
  storage_class_ids = [
    data.vcfa_storage_class.sc.id
  ]
}

resource "null_resource" "set_ntp" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOT
    sshpass -p "${local.password}" ssh -o StrictHostKeyChecking=no ${var.vcfo_orchestrator_username}@${var.vcfo_orchestrator_url} "vracli ntp systemd --set 10.1.1.1"
    EOT
  }
}
resource "null_resource" "set_password_file" {
  provisioner "local-exec" {
    command = <<EOT
    sshpass -p '${local.password}' ssh -o StrictHostKeyChecking=no ${var.vcfo_orchestrator_username}@${var.vcfo_orchestrator_url} "echo ${local.password} > /data/vco/usr/lib/vco/pwd.txt"
    vracli vro authentication set --force --ignore-certificate --provider=tm --username=${var.vcfa_username} --password-file="/usr/lib/vco/pwd.txt" --hostname=${format("https://%s", var.vcfa_url)} --tenant=${var.vcfa_tenant_org}
    /opt/scripts/deploy.sh
    EOF
    EOT
  }
}

resource "null_resource" "orchestrator_config" {
  provisioner "local-exec" {
    command = <<EOT
    sshpass -p '${local.password}' ssh -o StrictHostKeyChecking=no ${var.vcfo_orchestrator_username}@${var.vcfo_orchestrator_url} "vracli vro authentication set --force --ignore-certificate --provider=tm --username=${var.vcfa_username} --password-file="/usr/lib/vco/pwd.txt" --hostname=${format("https://%s", var.vcfa_url)} --tenant=${var.vcfa_tenant_org}"
    EOT
  }
}

resource "null_resource" "run_deploy_ssh" {
  provisioner "local-exec" {
    command = <<EOT
    sshpass -p '${local.password}' ssh -o StrictHostKeyChecking=no ${var.vcfo_orchestrator_username}@${var.vcfo_orchestrator_url} "/opt/scripts/deploy.sh"
    EOT
  }
}