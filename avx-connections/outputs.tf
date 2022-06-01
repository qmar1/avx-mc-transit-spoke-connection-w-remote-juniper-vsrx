/* # HA Enabled output
output "mc_s2c_xt_aw_apne2_01-vsrxonprem-01_w_ha" {
  value = local.avx_s2c_conn_details_withha_01
} */

# Non HA output
output "mc_s2c_xt_aw_apne2_01-vsrxonprem-01"{
   value = local.avx_s2c_conn_details_01
}


