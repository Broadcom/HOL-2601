
# RESOURCES

resource "vcfa_org_ldap" "rainpole-io" {
  org_id                 = vcfa_org.tenant_org.id
  ldap_mode              = "CUSTOM"
  auto_trust_certificate = false # Because is_ssl = false
  custom_settings {
    server                  = "ldap.site-a.vcf.lab"
    port                    = 389
    connector_type          = "OPEN_LDAP"
    base_distinguished_name = "dc=rainpole,dc=io"
    is_ssl                  = false
    username                = "cn=ldap.service,ou=service accounts,dc=rainpole,dc=io"
    password                = local.password
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
resource "vcfa_content_library" "cl" {
  org_id      = data.vcfa_org.tenant_org.id
  name        = var.tenant_content_library_name
  description = var.tenant_content_library_description
  storage_class_ids = [
    data.vcfa_storage_class.sc.id
  ]
}