## TF Output:
```sh
Outputs:

jump_host_info = {
  "availability_zone" = "us-east-1a"
  "private_ip" = "192.168.0.95"
  "public_ip" = "52.205.148.136"
  "vpc_security_group_ids" = toset([
    "sg-06faced1317655b49",
  ])
}
test_instance_pvt_ip = {
  "inst-qmar-onpremsim-vpc-us-east-1a-1" = "192.168.2.161"
  "inst-qmar-onpremsim-vpc-us-east-1a-2" = "192.168.2.91"
  "inst-qmar-onpremsim-vpc-us-east-1b-1" = "192.168.5.171"
  "inst-qmar-onpremsim-vpc-us-east-1b-2" = "192.168.5.147"
  "inst-qmar-onpremsim-vpc-us-east-1c-1" = "192.168.8.78"
  "inst-qmar-onpremsim-vpc-us-east-1c-2" = "192.168.8.75"
}
vsrx_info = {
  "vsrxgw-us-east-1a-qmar-onpremsim-vpc" = {
    "fxp0_pub_ip" = "44.205.234.134"
    "fxp0_pvt_ip" = "192.168.0.174"
    "internet_pub_ip" = "44.205.191.218"
    "internet_pvt_ip" = "192.168.1.133"
    "lan_pvt_ip" = "192.168.2.113"
  }
  "vsrxgw-us-east-1b-qmar-onpremsim-vpc" = {
    "fxp0_pub_ip" = "34.202.218.3"
    "fxp0_pvt_ip" = "192.168.3.78"
    "internet_pub_ip" = "54.211.206.45"
    "internet_pvt_ip" = "192.168.4.160"
    "lan_pvt_ip" = "192.168.5.68"
  }
  "vsrxgw-us-east-1c-qmar-onpremsim-vpc" = {
    "fxp0_pub_ip" = "3.217.183.103"
    "fxp0_pvt_ip" = "192.168.6.93"
    "internet_pub_ip" = "52.44.251.161"
    "internet_pvt_ip" = "192.168.7.153"
    "lan_pvt_ip" = "192.168.8.181"
  }
}
```

### SSH to test instance using jump host

```
ssh -J ubuntu@<jump_host_pub_ip> ubuntu@<test_inst_pvt_ip>
```

Eg:
```sh
ssh -J ubuntu@52.205.148.136 ubuntu@192.168.5.171
```