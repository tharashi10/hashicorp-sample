// resource "oci_identity_user" "sample_user" {
//   compartment_id = oci_identity_compartment.default.id
//   description    = "oci sample user"
//   name           = var.user_names[count.index]
//   count          = length(var.user_names)
//   defined_tags   = { "Owner" = "TeamXYZ", "ManagedBy" = "Terraform" }
// }

resource "oci_identity_user" "sample_users_for_each" {
  for_each       = toset(var.user_names) // set or map
  name           = each.value
  compartment_id = "ocid1.tenancy.oc1..aaaaaaaamu4bvfwi2pkyutoags7ws3t6jnfrbfwgcwiwzqziuwuikunj772q"
  description    = "oci sample user"
  defined_tags   = { "Owner" = "TeamXYZ", "ManagedBy" = "Terraform" }
}

output "all_users" {
  value = oci_identity_user.sample_users_for_each
}

output "all_users_ids_list_compression" {
  value = [for name in var.user_names : upper(name)]
}
