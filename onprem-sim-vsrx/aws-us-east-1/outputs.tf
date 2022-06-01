output "vsrx_instance_ids" {
  value = { for index, vsrx in module.vsrx_aws.vsrx_info : vsrx.tags.Name => vsrx.id }
}

output "vsrx_info" {
  value = local.vsrx_info
}

output "jump_host_info" {
  value = { for attr in local.jmp_host_attributes_tocollect : attr => module.vsrx_aws.jump_host_info[attr] }
}

output "test_instance_pvt_ip" {
  value = { for instance in module.vsrx_aws.test_instance_info : instance.tags.Name => instance.private_ip }
}








