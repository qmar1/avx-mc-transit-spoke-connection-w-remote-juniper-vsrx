# To AWS GW OR condition
# No HA on the remote side - only one remote device
resource "aviatrix_transit_external_device_conn" "mc_s2c_xt_01-vsrxonprem-01" {
  vpc_id            = data.aviatrix_transit_gateway.xt_aws_gw_01.vpc_id
  connection_name   = "xt-aw-apne2-01-vsrxonprem-01"
  gw_name           = "xt-aw-apne2-01-gw"
  connection_type   = "bgp"
  bgp_local_as_num  = "65500"
  bgp_remote_as_num = "65512"
  remote_gateway_ip = local.vsrx_pubip_primary

  # Optional
  tunnel_protocol          = "IPsec"
  pre_shared_key           = "Juniper123#"
  phase1_remote_identifier = [local.vsrx_pvtip_primary]
  enable_edge_segmentation = false
  local_tunnel_cidr        = "169.254.1.1/30,169.254.2.1/30"
  remote_tunnel_cidr       = "169.254.1.2/30,169.254.2.2/30"

}


/* # With HA on the remote side - 2 devices A-A # xcross thingie
resource "aviatrix_transit_external_device_conn" "mc_s2c_xt_01-vsrxonprem-01_with_ha" {
  vpc_id            = data.aviatrix_transit_gateway.xt_aws_gw_01.vpc_id
  connection_name   = "xt-aw-apne2-01-vsrxonprem-01-w-ha"
  gw_name           = "xt-aw-apne2-01-gw"
  connection_type   = "bgp"
  bgp_local_as_num  = "65500"
  bgp_remote_as_num = "65512"
  remote_gateway_ip = local.vsrx_pubip_primary

  # Optional
  ha_enabled                = true
  tunnel_protocol           = "IPsec"
  pre_shared_key            = "Juniper123#"
  phase1_remote_identifier  = [local.vsrx_pvtip_primary, local.vsrx_pvtip_backup]
  enable_edge_segmentation  = false
  local_tunnel_cidr         = "169.254.1.1/30,169.254.2.1/30"
  remote_tunnel_cidr        = "169.254.1.2/30,169.254.2.2/30"
  backup_bgp_remote_as_num  = "65512"
  backup_pre_shared_key     = "Juniper123#"
  backup_remote_gateway_ip  = local.vsrx_pubip_backup
  backup_local_tunnel_cidr  = "169.254.11.1/30,169.254.12.1/30"
  backup_remote_tunnel_cidr = "169.254.11.2/30,169.254.12.2/30"

} */

/* resource "aviatrix_segmentation_network_domain" "" {
  domain_name = "domain-a"
} */

resource "aviatrix_segmentation_network_domain_association" "segment_s2c_xt_ass" {
  transit_gateway_name = "xt-aw-apne2-01-gw"
  network_domain_name = "coreInfra"
  attachment_name      = aviatrix_transit_external_device_conn.mc_s2c_xt_01-vsrxonprem-01.connection_name
}

# Full mesh Transit GW peering

module "transit-peering" {
  source  = "terraform-aviatrix-modules/mc-transit-peering/aviatrix"
  version = "1.0.6"

  transit_gateways = [
    data.aviatrix_transit_gateway.xt_aws_gw_01.gw_name,
    data.aviatrix_transit_gateway.xt_az_gw_01.gw_name,
  ]

  /*   excluded_cidrs = [
    0.0.0.0/0,
  ] */
}

## Data block 
data "aviatrix_transit_gateway" "xt_aws_gw_01" {
  gw_name = "xt-aw-apne2-01-gw"

}

data "aviatrix_transit_gateway" "xt_az_gw_01" {
  gw_name = "az-xt-wus2-01-gw"
}

data "terraform_remote_state" "onprem_sim_vsrx_data" {

  backend = "s3"

  config = {
    bucket  = "qmar-avx-tf-backed-state-2022"
    key     = "prod-rdy/onprem-sim-vsrx/aws-us-east-1/terraform.tfstate"
    region  = "us-east-1"
    profile = "kumar"
  }
}
