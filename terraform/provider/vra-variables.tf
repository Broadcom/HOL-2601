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