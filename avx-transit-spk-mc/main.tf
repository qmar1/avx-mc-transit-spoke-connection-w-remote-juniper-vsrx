
# AWS Transit 

module "aws_xt_apne2_01" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.1.1"

  cloud         = "AWS"
  region        = "ap-northeast-2"
  cidr          = "10.101.0.0/16"
  account       = "qmar-aws-primary"
  insane_mode   = true
  instance_size = "c5.xlarge" #Non-default value required, as minimum instance size for Insane Mode is c5.large

  # Optional parameter

  enable_advertise_transit_cidr = true
  enable_encrypt_volume         = true
  local_as_number               = var.aws_xt_local_as_num
  name                          = "xt-aw-apne2-01"
  gw_name                       = "xt-aw-apne2-01-gw"
  single_az_ha                  = false
  enable_segmentation           = true
  enable_transit_firenet        = false
}

# Azure Transit

module "az_xt_wus2_01" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.1.1"

  cloud         = "Azure"
  region        = "West US 2"
  cidr          = "10.121.0.0/16"
  account       = "qmar-az-primary"
  insane_mode   = true
  instance_size = "Standard_D3_v2" #Non-default value required, as minimum instance size for Insane Mode is <>

  # Optional parameter
  az_support                    = true
  enable_advertise_transit_cidr = true
  #enable_encrypt_volume         = false # not supported in AZ/GCP/OCI
  local_as_number        = var.az_xt_local_as_num
  name                   = "az-xt-wus2-01"
  gw_name                = "az-xt-wus2-01-gw"
  single_az_ha           = false
  enable_segmentation    = true
  enable_transit_firenet = false
}


# GCP Transit 

/* module "gcp_xt_euw2_01" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.0.2"

  cloud         = "GCP"
  region        = "europe-west2"
  cidr          = "10.141.0.0/16"
  account       = "qmar-gcp-primary"
  insane_mode   = true
  instance_size = "n1-highcpu-4" #Non-default value required, as minimum instance size for Insane Mode is c5.large

  # Optional parameter

  enable_advertise_transit_cidr = true
  enable_encrypt_volume         = false # not supported in AZ/GCP/OCI
  local_as_number               = 65503
  name                          = "xt-gc-euw2-01"
  gw_name                       = "xt-gc-euw2-01-gw"
  single_az_ha                  = false
  enable_segmentation           = true
  enable_transit_firenet        = true
} */


# AWS Spoke 
module "sp-aw-aps1-01" {
  # Mumbai region
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.2.1"

  cloud      = "AWS"
  name       = "sp-aw-aps1-01"
  cidr       = "10.1.0.0/16"
  region     = "ap-south-1"
  account    = "qmar-aws-primary"
  transit_gw = module.aws_xt_apne2_01.transit_gateway.gw_name

  # optional 
  network_domain = "coreInfra"
  single_az_ha   = false
  insane_mode    = false
  instance_size  = "t3.medium"
}

# Insane mode AWS spoke

module "sp-aw-apne2-01" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.2.1"

  cloud          = "AWS"
  name           = "sp-aw-apne2-01"
  cidr           = "10.2.0.0/16"
  region         = "ap-northeast-2"
  account        = "qmar-aws-primary"
  transit_gw     = module.aws_xt_apne2_01.transit_gateway.gw_name
  network_domain = "coreInfra"
  # optional 
  #security_domain = ""
  single_az_ha  = false
  insane_mode   = true
  instance_size = "t3.large" # Verify if this is supported 
}

# Azure Spoke 
module "sp_az_wus2_01" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.2.1"

  cloud          = "Azure"
  name           = "sp-az-wus2-01"
  cidr           = "10.21.0.0/16"
  region         = "West US 2"
  account        = "qmar-az-primary"
  transit_gw     = module.az_xt_wus2_01.transit_gateway.gw_name
  network_domain = "coreInfra"
  single_az_ha   = false
  insane_mode    = true
  instance_size = "Standard_D3_v2"
  az_support = true
}

module "sp_az_eus2_01" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.2.1"

  cloud          = "Azure"
  name           = "sp-az-eus2-01"
  cidr           = "10.22.0.0/16"
  region         = "East US 2"
  account        = "qmar-az-primary"
  transit_gw     = module.az_xt_wus2_01.transit_gateway.gw_name
  network_domain = "coreInfra"
  single_az_ha   = false
  insane_mode    = false
  #  instance_size  = ""
  az_support = true
}


# GCP Spoke
