variable "password_file_path" {
  type        = string
  description = "The path to the file containing the password for the VCF Automation API"
  default     = "/home/holuser/creds.txt"
}
variable "vcfa_url" {
  type        = string
  description = "The VCF Automation URL"
  default     = "auto-a.site-a.vcf.lab"
}
variable "vcfa_insecure" {
  type        = bool
  description = "Whether to validate the VCF Automation TLS certificates"
  default     = "true"
}
variable "vcfa_refresh_token" {
  type        = string
  description = "The VCF Automation refresh token"
  sensitive   = true
}
variable "vcfa_tenant_org_username" {
  type        = string
  description = "The VCF Automation username"
  sensitive   = true
}
variable "vcfa_tenant_org_password" {
  type        = string
  description = "The VCF Automation password"
  sensitive   = true
}
variable "vcfa_tenant_org" {
  type        = string
  description = "The VCF Automation organization"
  sensitive   = true
}
variable "vcfa_tenant_org_log_file" {
  type        = string
  description = "The VCF Automation log file path"
  default     = "system"
}

# vcenter
variable "wld_vcenter_url" {
  type        = string
  description = "The vCenter URL to connect to"
}
variable "wld_vcenter_username" {
  type        = string
  description = "The vCenter username"
}
variable "wld_vcenter_password" {
  type        = string
  description = "The vCenter password"
}
variable "wld_vcenter_storage_policy_names" {
  type        = list(string)
  description = "The names of the vCenter storage policies to use"
}

# NSX 
variable "nsx_manager_url" {
  type        = string
  description = "The NSX Manager URL to connect to"
}
variable "nsx_manager_username" {
  type        = string
  description = "The NSX Manager username"
}
variable "nsx_manager_password" {
  type        = string
  description = "The NSX Manager password"
}
variable "nsx_tier0_gateway_name" {
  type        = string
  description = "The name of the NSX Tier-0 gateway"
}
variable "nsx_edge_cluster_name" {
  type        = string
  description = "The name of the NSX edge cluster"
}

# Supervisor
variable "supervisor_name" {
  type        = string
  description = "The name of the Supervisor Cluster to connect to"
}
variable "region_name" {
  type        = string
  description = "The name of the region to create"
}
variable "supervisor_zone_name" {
  type        = string
  description = "The name of the supervisor zone"
}

# Org

variable "vcfa_tenant_org_content_library_name" {
  type        = string
  description = "The name of the Tenant content library to use"
}
variable "vcfa_tenant_org_content_library_description" {
  type        = string
  description = "The description of the Tenant content library to use"
}

variable "vcfa_tenant_org_content_library_name" {
  type        = string
  description = "The name of the Tenant content library to use"
}
variable "vcfa_tenant_org_content_library_description" {
  type        = string
  description = "The description of the Tenant content library to use"
}

variable "ldap_host" {
  type        = string
  description = "The LDAP host to connect to"
}
variable "ldap_port" {
  type        = number
  description = "The LDAP port to connect to"
  default     = 389
}

variable "ldap_bind_dn" {
  type        = string
  description = "The LDAP bind DN"
} 
variable "ldap_password" {
  type        = string
  description = "The LDAP password"
  sensitive   = true
}

variable "ldap_ssl" {
  type        = bool
  description = "Whether to use SSL for the LDAP connection"
  default     = false
}

variable "ldap_search_base" {
  type        = string
  description = "The LDAP search base"
}

