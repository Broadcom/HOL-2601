vcfa_url = "auto-a.site-a.vcf.lab"
vcfa_insecure = true
vcfa_refresh_token = ""
vcfa_password = ""
vcfa_username = "admin"
vcfa_org = "system"
vcfa_log_file = "vcfa.log"

wld_vcenter_url = "vc-wld01-a.site-a.vcf.lab"
wld_vcenter_username = "administrator@wld.sso"
wld_vcenter_password = ""
wld_vcenter_storage_policy_names = [ "vSAN Default Storage Policy" ]

nsx_wld01_manager_url = "nsx-wld01-a.site-a.vcf.lab"
nsx_wld01_manager_username = "admin"
nsx_wld01_manager_password = ""
nsx_wld01_tier0_gateway_name = "t0-wld-a"
nsx_wld01_edge_cluster_name = "edgecl-wld-a"

ipspace_max_subnet_size = 24
ipspace_max_cidr_count = 10
ipspace_max_ip_count = 100
ipspace_scope_cidr1 = "10.0.0.0/8"

supervisor_name = "supervisor"
region_name = "region-a"
supervisor_zone_name = "z-wld-a"
region_storage_policy_names = [ "vSAN Default Storage Policy" ]
region_vm_class_names = ["best-effort-large", "best-effort-medium", "best-effort-small", "best-effort-xsmall"]

region_quota_cpu_limit_mhz = 1000
region_quota_cpu_reservation_mhz = 500
region_quota_mem_limit_mb = 2048
region_quota_mem_reservation_mb = 1024
region_quota_storage_limit_mb = 10240

tenant_content_library_name = "Organization"
tenant_content_library_description = "Tenant Content Library"

vcfa_tenant_org = "hol-all-apps"
org_local_username = "admin"
org_local_password = ""
org_log_name = "all-apps"

nsx_wld01_project = "hol-all-apps"
