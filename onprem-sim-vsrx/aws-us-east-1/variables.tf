
locals {
  jmp_host_attributes_tocollect = ["private_ip", "public_ip", "availability_zone", "vpc_security_group_ids"]
  vsrxgw_names                  = keys(module.vsrx_aws.vsrx_info)
  vsrx_values = flatten([
    for index, az in module.vsrx_aws.azs_used : {
      fxp0_pvt_ip     = module.vsrx_aws.vsrx_info[local.vsrxgw_names[index]]["private_ip"]
      fxp0_pub_ip     = module.vsrx_aws.vsrx_eip["${az}-management"]["public_ip"]
      internet_pvt_ip = module.vsrx_aws.vsrx_eni["${az}-internet-eni"]["private_ip"]
      internet_pub_ip = module.vsrx_aws.vsrx_eip["${az}-internet"]["public_ip"]
      lan_pvt_ip      = module.vsrx_aws.vsrx_eni["${az}-lan-eni"]["private_ip"]
    }
  ])

  vsrx_info = zipmap(local.vsrxgw_names, local.vsrx_values)

}
