
# RESOURCES

resource "vcfa_api_token" "tenant_api_token" {
  name             = "tenant_token"
  file_name        = "${path.cwd}/tenant_token.json"
  allow_token_file = true
}

output "api_token" {
  value = vcfa_api_token.tenant_api_token.refresh_token
}

resource "null_resource" "api_" {
 depends_on = [vcfa_api_token.system_api_token]
   provisioner "local-exec" {
    command = <<EOT
    curl -k -X PUT "https://${var.vcfa_url}/api/v1/system/api-tokens/${vcfa_api_token.system_api_token.id}" \
      -H "accept: application/json" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer ${vcfa_api_token.system_api_token.refresh_token}" \
      -u "${var.vcfa_username}:${local.password}" \
      -d '{"name":"system_token","file_name":"${path.cwd}/system_token.json","allow_token_file":true}' 
    EOT
  }
}


resource "vcfa_org_ldap" "rainpole-io" {
  org_id                 = vcfa_org.tenant_org.id
  ldap_mode              = "CUSTOM"
  auto_trust_certificate = false # Because is_ssl = false
  custom_settings {
    server                  = var.ldap_host
    port                    = var.ldap_port
    is_ssl                  = var.ldap_ssl
    username                = var.ldap_bind_dn
    password                = local.password
    base_distinguished_name = var.ldap_search_base
    connector_type          = "OPEN_LDAP"
    user_attributes {
      object_class                = "person"
      unique_identifier           = "entryUUID"
      username                    = "cn"
      display_name                = "displayName"
      given_name                  = "givenName"
      surname                     = "sn"
      email                       = "mail"
      telephone                   = "telephoneNumber"
      group_membership_identifier = "dn"

    }
    group_attributes {
      object_class                = "groupOfNames"
      unique_identifier           = "entryUUID"
      name                        = "cn"
      membership                  = "member"
      group_membership_identifier = "dn"
    }
  }
}


# Create Content Library
resource "vcfa_content_library" "tenant_cl" {
  org_id      = data.vcfa_org.tenant_org.id
  name        = var.vcfa_tenant_org_content_library_name
  description = var.vcfa_tenant_org_content_library_description
  storage_class_ids = [
    data.vcfa_storage_class.sc.id
  ]
}