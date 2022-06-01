variable "controller_ip" {
  type        = string
  description = "IP address of the Aviatrix Controller"
}

variable "ctrl_user_name" {
  type        = string
  description = "Aviatrix controller user name"
}

variable "ctrl_psswd" {
  type        = string
  description = "Aviatrix controller password"
}

variable "ha_gw" {
  type = bool
  default  = false  
}

# HA enabled Locals
/* locals {

  avx_gw_tunnel_ips        = aviatrix_transit_external_device_conn.mc_s2c_xt_01-vsrxonprem-01_with_ha.local_tunnel_cidr
  avx_gw_backup_tunnel_ips = aviatrix_transit_external_device_conn.mc_s2c_xt_01-vsrxonprem-01_with_ha.backup_local_tunnel_cidr

  # HA Enabled connection details
  avx_s2c_conn_details_withha_01 = tomap(
    {
      "tunnel_ip_pri_gw"        = split(",", local.avx_gw_tunnel_ips)[0]
      "tunnel_ip_ha_gw"         = split(",", local.avx_gw_tunnel_ips)[1]
      "backup_tunnel_ip_pri_gw" = split(",", local.avx_gw_backup_tunnel_ips)[0]
      "backup_tunnel_ip_ha_gw"  = split(",", local.avx_gw_backup_tunnel_ips)[1]
      "avx_gw_as_num"           = aviatrix_transit_external_device_conn.mc_s2c_xt_01-vsrxonprem-01_with_ha.bgp_local_as_num
      "remote_as_num"           = aviatrix_transit_external_device_conn.mc_s2c_xt_01-vsrxonprem-01_with_ha.bgp_remote_as_num
      "avx_pri_gw_pubip"        = data.aviatrix_transit_gateway.xt_aws_gw_01.public_ip
      "avx_ha_gw_pubip"         = data.aviatrix_transit_gateway.xt_aws_gw_01.ha_public_ip

    }
  )

  # Getting remote on prem simulated vSRX information from remote state file  
  # Only need to get Public IP of the vSRX 
  vsrx_names         = keys(data.terraform_remote_state.onprem_sim_vsrx_data.outputs.vsrx_info)
  vsrx_pubip_primary = data.terraform_remote_state.onprem_sim_vsrx_data.outputs.vsrx_info[local.vsrx_names[0]]["internet_pub_ip"]
  vsrx_pubip_backup  = data.terraform_remote_state.onprem_sim_vsrx_data.outputs.vsrx_info[local.vsrx_names[1]]["internet_pub_ip"]
  vsrx_pvtip_primary = data.terraform_remote_state.onprem_sim_vsrx_data.outputs.vsrx_info[local.vsrx_names[0]]["internet_pvt_ip"]
  vsrx_pvtip_backup  = data.terraform_remote_state.onprem_sim_vsrx_data.outputs.vsrx_info[local.vsrx_names[1]]["internet_pvt_ip"]

} */

  #--------------------------------Non HA Connection--------------------------
locals {
  
  avx_gw_tunnel_ips        = aviatrix_transit_external_device_conn.mc_s2c_xt_01-vsrxonprem-01.local_tunnel_cidr
  avx_s2c_conn_details_01 = tomap(
    {
      "tunnel_ip_pri_gw" = split(",", local.avx_gw_tunnel_ips)[0]
      "tunnel_ip_ha_gw"  = split(",", local.avx_gw_tunnel_ips)[1]
      "avx_gw_as_num"    = aviatrix_transit_external_device_conn.mc_s2c_xt_01-vsrxonprem-01.bgp_local_as_num
      "remote_as_num"    = aviatrix_transit_external_device_conn.mc_s2c_xt_01-vsrxonprem-01.bgp_remote_as_num
      "avx_pri_gw_pubip" = data.aviatrix_transit_gateway.xt_aws_gw_01.public_ip
      "avx_ha_gw_pubip"  = data.aviatrix_transit_gateway.xt_aws_gw_01.ha_public_ip
    }
  )

  vsrx_names         = keys(data.terraform_remote_state.onprem_sim_vsrx_data.outputs.vsrx_info)
  vsrx_pubip_primary = data.terraform_remote_state.onprem_sim_vsrx_data.outputs.vsrx_info[local.vsrx_names[0]]["internet_pub_ip"]
  vsrx_pvtip_primary = data.terraform_remote_state.onprem_sim_vsrx_data.outputs.vsrx_info[local.vsrx_names[0]]["internet_pvt_ip"]

}