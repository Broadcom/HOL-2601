data "vcfa_version" "version" {
    condition         = ">= 9.0.0"
    fail_if_not_match = false
}

data "vcfa_vcenter" "vc" {
    name = replace(var.wld_vcenter_url, "https://", "")
}
data "vcfa_supervisor" "sv" {
    name = var.supervisor_name
    vcenter_id = data.vcfa_vcenter.vc.id
}

data "vcfa_nsx_manager" "nsx" {
  name = replace(var.nsx_manager_url, "https://", "")
}

data "vcfa_region_zone" "zone" {
  region_id = vcfa_region.region.id
  name      = var.supervisor_zone_name
}




data "vcfa_edge_cluster" "edge-cluster" {
  name             = var.nsx_edge_cluster_name
  region_id        = vcfa_region.region.id
  sync_before_read = true
}

data "vcfa_tier0_gateway" "t0-gw" {
  name      = var.nsx_tier0_gateway_name
  region_id = vcfa_region.region.id
}

data "vcfa_org" "system" {
  name = "System"
}

data "vcfa_rights_bundle" "orch-rights-bundle" {
  name = "Orchestrator Rights Bundle"
}


data "vcfa_role" "org-admin" {
  org_id = vcfa_org.tenant_org.id
  name   = "Organization Administrator"
}


data "local_file" "token" {
  filename = vcfa_api_token.tenant_api_token.file_name
  depends_on = [ vcfa_api_token.tenant_api_token ]
}
