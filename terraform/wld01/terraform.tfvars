vsphere_server = "vc-wld01-a.site-a.vcf.lab"
vsphere_password = local.password
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
nsx_wld01_manager_password = local.password
nsx_wld01_project = "hol-all-apps"