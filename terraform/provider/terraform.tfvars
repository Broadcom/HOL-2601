vcfa_url = "auto-a.site-a.vcf.lab"
vcfa_insecure = true
vcfa_refresh_token = ""
vcfa_password = ""
vcfa_username = "admin"
vcfa_org = "system"
vcfa_log_file = "vcfa.log"
vcfa_username_pwd_file = "/usr/lib/vco/pwd.txt"
vcfa_fullpath_password_file = "/data/vco/usr/lib/vco/pwd.txt"


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
region_quota_mem_limit_mb = 51200
region_quota_mem_reservation_mb = 0
region_quota_storage_limit_mb = 1024000

global_content_library_name = "Provider"
global_content_library_description = "Provider Content Library"

vcfa_tenant_org_content_library_description = "Provider Content Library"
vcfa_tenant_org_content_library_name = "Tenant"

vcfa_tenant_org = "hol-all-apps"
vcfa_tenant_org_local_username = "admin"
vcfa_tenant_org_local_password = ""
vcfa_tenant_org_log_name = "all-apps"

vsphere_server = "vc-wld01-a.site-a.vcf.lab"
vsphere_password = ""
vsphere_username = "administrator@wld.sso"
datacenter = "dc-a"
cluster = "cluster-wld01-01a"
datastore = "vsan-wld01-01a"
network = "mgmt-vds01-wld01-01a"
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


ldap_bind_dn = "cn=ldap.service,ou=service accounts,dc=rainpole,dc=io"
ldap_host = "ldap.site-a.vcf.lab"
ldap_port = 389
ldap_search_base = "dc=rainpole,dc=io"
ldap_ssl = false
ldap_password = ""


vcfo_orchestrator_password = ""
vcfo_orchestrator_url = "o11n-01a.site-a.vcf.lab"
vcfo_orchestrator_username = "root"
vcfa_orchestrator_rights_bundle = "Orchestrator Rights Bundle"