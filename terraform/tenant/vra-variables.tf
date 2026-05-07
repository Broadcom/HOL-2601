variable "vra_url" {
  type        = string
  description = "The VCF Automation URL"
  default     = "auto-a.site-a.vcf.lab"
}
variable "vra_insecure" {
  type        = bool
  description = "Whether to validate the VCF Automation TLS certificates"
  default     = "true"
}

variable "gitlab_token_file_path" {
  type        = string
  description = "The path to the file containing the GitLab token"
  default     = "/home/holuser/gitlab.txt"
}

variable "gitlab_integration_name" {
  type        = string
  description = "The name of the GitLab integration in VCF Automation"
  default     = "gitlab"
}
variable "gitlab_integration_description" {
  type        = string
  description = "The description of the GitLab integration in VCF Automation"
  default     = "GitLab integration"
}
variable "gitlab_integration_url" {
  type        = string
  description = "The URL of the GitLab instance to integrate with VCF Automation (without https://)"
  default     = "gitlab.site-a.vcf.lab"
}