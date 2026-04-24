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

nsx_manager_url = "nsx-wld01-a.site-a.vcf.lab"
nsx_manager_username = "admin"
nsx_manager_password = ""
nsx_tier0_gateway_name = "t0-wld-a"
nsx_edge_cluster_name = "edgecl-wld-a"

ipspace_max_subnet_size = 24
ipspace_max_cidr_count = 10
ipspace_max_ip_count = 100
ipspace_scope_cidr1 = "10.0.0.0/8"

supervisor_name = "supervisor"
region_name = "region-a"
supervisor_zone_name = "z-wld-a"
region_storage_policy_names = [ "vSAN Default Storage Policy" ]
region_vm_class_names = ["best-effort-large", "best-effort-medium", "best-effort-small", "best-effort-xsmall"]

region_quota_cpu_limit_mhz = 25000
region_quota_cpu_reservation_mhz = 0
region_quota_mem_limit_mb = 51,200
region_quota_mem_reservation_mb = 0
region_quota_storage_limit_mb = 1024000

global_content_library_name = "Provider"
global_content_library_description = "Provider Content Library"

org_name = "hol-all-apps"
org_local_username = "admin"
org_local_password = ""
org_log_name = "all-apps"

vsphere_server = "vc-wld01-a.site-a.vcf.lab"
vsphere_password = ""
vsphere_username = "administrator@wld.sso"
datacenter = "wld-01a-DC"
cluster = "cluster-wld01-01a"
datastore = "vsanDatastore"
network = "mgm-vds01-wld01-01a"
template_name = "ubuntu-24-04-base"
vm_name = "hol-snapshot-001"
vm_hostname = "esx-05a.site-a.vcf.lab"
vm_domain = "site-a.vcf.lab"
vm_folder = ""
vm_cpus = 1
vm_memory = 4096
vm_disk_size = 40
vm_ipv4_address = "10.1.1.237"
vm_ipv4_dns_servers = [ "10.1.1.1" ]
vm_ipv4_gateway = "10.1.1.1"
vm_ipv4_netmask = 24


nsx_wld01_manager_url = "nsx-wld01-a.site-a.vcf.lab"
nsx_wld01_manager_username = "admin"
nsx_wld01_manager_password = ""