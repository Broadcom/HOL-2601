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

data "vcfa_region_vm_class" "vm_class1" {
  name      = tolist(var.region_vm_class_names)[0]
  region_id = vcfa_region.region.id
}

data "vcfa_region_vm_class" "vm_class2" {
  name      = tolist(var.region_vm_class_names)[1]
  region_id = vcfa_region.region.id
}

data "vcfa_region_vm_class" "vm_class3" {
  name      = tolist(var.region_vm_class_names)[2]
  region_id = vcfa_region.region.id
}

data "vcfa_region_vm_class" "vm_class4" {
  name      = tolist(var.region_vm_class_names)[3]
  region_id = vcfa_region.region.id
}

data "vcfa_region_storage_policy" "region-sc" {
  name      = tolist(var.region_storage_policy_names)[0]
  region_id = vcfa_region.region.id
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

data "nsxt_policy_project" "hol-all-apps" {
  display_name = var.nsx_wld01_project
}