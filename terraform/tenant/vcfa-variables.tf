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
variable "vcfa_username" {
  type        = string
  description = "The VCF Automation username"
  sensitive   = true
}
variable "vcfa_password" {
  type        = string
  description = "The VCF Automation password"
  sensitive   = true
}
variable "vcfa_org" {
  type        = string
  description = "The VCF Automation organization"
  sensitive   = true
}
variable "vcfa_log_file" {
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

# Region
variable "region_storage_policy_names" {
  type        = list(string)
  description = "The names of the region storage policies to use"
}
variable "region_vm_class_names" {
  type        = list(string)
  description = "The names of the region VM classes to use"
}

variable "region_quota_cpu_limit_mhz" {
  type        = number
  description = "The CPU limit for the region quota"
}

variable "region_quota_cpu_reservation_mhz" {
  type        = number
  description = "The CPU reservation for the region quota"
}

variable "region_quota_mem_limit_mb" {
  type        = number
  description = "The memory limit for the region quota"
}

variable "region_quota_mem_reservation_mb" {
  type        = number
  description = "The memory reservation for the region quota"
}
variable "region_quota_storage_limit_mb" {
  type        = number
  description = "The storage limit for the region quota"
}

# Org

variable "vcfa_tenant_org" {
  type        = string
  description = "The name of the org to create"
}

variable "org_log_name" {
  type        = string
  description = "The log name for the org"
}
variable "org_local_username" {
  type        = string
  description = "The local username for the org"
}
variable "org_local_password" {
  type        = string
  description = "The local password for the org"
}

variable "tenant_content_library_name" {
  type        = string
  description = "The name of the Tenant content library to use"
}
variable "tenant_content_library_description" {
  type        = string
  description = "The description of the Tenant content library to use"
}
variable "ipspace_max_subnet_size" {
  type        = number
  description = "The maximum subnet size for the IP space"
  default     = 24
}

variable "ipspace_max_cidr_count" {
  type        = number
  description = "The maximum number of CIDR blocks for the IP space"
  default     = 10
}

variable "ipspace_max_ip_count" {
  type        = number
  description = "The maximum number of IP addresses for the IP space"
  default     = 100
}

variable "ipspace_scope_cidr1" {
  type        = string
  description = "The CIDR block for the IP space scope"
  default     = "10.0.0.0/8"
}

#