resource "oci_identity_compartment" "default" {
  compartment_id = var.provider_tenancy_ocid
  name = var.create_compartment_name
  description = var.create_compartment_description
}

resource "oci_core_vcn" "default" {
  display_name   = "${var.project_prefix}-VCN"
  cidr_block     = var.vcn_cidr_block
  compartment_id = oci_identity_compartment.default.id
  dns_label      = var.vcn_dns_label
}

resource "oci_core_security_list" "default" {
  compartment_id = oci_identity_compartment.default.id
  vcn_id = oci_core_vcn.default.id
  display_name = "${var.project_prefix}-Default-Sl"
  egress_security_rules {
    destination = var.sl_egress_destination_prv
    protocol    = var.sl_egress_protocol_prv
    stateless   = false
  }
  ingress_security_rules {
    source     = var.sl_ingress_source_prv     
    protocol   = var.sl_ingress_protocol_prv
    stateless  = false
    tcp_options {
      max = var.sl_ingress_tcp_dest_port_max_prv
      min = var.sl_ingress_tcp_dest_port_min_prv
    }
  }
}

data "oci_core_services" "default" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

# Service Gatewayの構成
#resource "oci_core_service_gateway" "default" {
#  display_name = "${var.project_prefix}-SGW"
#  compartment_id = oci_identity_compartment.default.id
#  vcn_id = oci_core_vcn.default.id
#
#  services {
#    service_id = data.oci_core_services.default.services[0]["id"]
#  }
#}

# ルート表の構成
resource "oci_core_route_table" "default" {
  display_name   = "${var.project_prefix}-Rt"
  compartment_id = oci_identity_compartment.default.id
  vcn_id = oci_core_vcn.default.id
}
#  route_rules {
#    destination       = data.oci_core_services.default.services[0]["cidr_block"]
#    destination_type  = "SERVICE_CIDR_BLOCK"
#    network_entity_id = oci_core_service_gateway.default.id
#  }
#}

# NAT構成
#resource "oci_core_nat_gateway" "default" {
#  compartment_id = oci_identity_compartment.default.id
#  vcn_id         = oci_core_vcn.default.id
#  display_name   = "${var.project_prefix}-NAT"
#}


# HTTP バックエンド構成
# terraform {
#   backend "http" {
#    address = "https://objectstorage.ap-tokyo-1.oraclecloud.com/p/CcoyKZCIdw9RlYckfsquFAZvMG37Wj_-BiwdFT0fdPAaiodH-rL_oQWFmpbV3zqO/n/nrp0revoo1zt/b/bucket-tfstate/o/terraform.tfstate"
#    update_method = "PUT"
#   }
# }