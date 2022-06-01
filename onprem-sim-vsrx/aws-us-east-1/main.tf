# Repeat Module for each region use provider = 'alias'
# for each region other than the primary one 
# example: 
# provider "aws" {
#  alias   = "us-east-2"
#  region  = "us-east-2"
#  profile = "Profile_name"
# }
# Better option is to create a seperate folder for each region and copy these files and run tf apply from each folder
# Note: If you change the module name then ensure to replace the module name in variables.tf file, outputs.tf file as well
# You can set the aws credentials using environment variables or using aws configure. For aws configure you will need
# aws cli installed. 

module "vsrx_aws" {
  # Need to provide proper source here with relative path etc ... #TBD# 
  source = "github.com/qmar1/tf_aws_juniper_vsrx"

  #------------------REQUIRED VALUES--------------------------------------
  # Modify these values according to your requirements 

  prefix            = "qmar" # This helps you easily identify your resources in a shared account
  vpc_name          = "onpremsim-vpc"
  cidr_block        = "192.168.0.0/16"        # Has to be a /16  
  key_name          = "qmar-personal-mbp-key" # Same key will be used for all instances 
  vsrx_ami_ssm_name = "vsrx-us-east-1"
  aws_cfg_profile   = "kumar"   
  region            = "us-east-1"

  #----------8<--------END REQUIRED VALUES-------->8------------------------

  #------------------OPTIONAL VALUES----------------------------------------
  /*
 no_of_secgw_in_azs (int) cannot be more than total AZ in a region 
 You can find number of AZ in a given region by using aws CLI: 
 aws ec2 describe-availability-zones --profile <aws cli profile> --output text --region us-east-1
*/

  no_of_secgw_in_azs = 1 # This cannot be more than total AZ in a region
  vsrx_instance_type = "c5.xlarge"

  # Note: Test instances will be deployed in the LAN subnet 

  num_of_test_instances_per_lansubnet = 1
  test_instance_type                  = "t2.micro"
  test_inst_ami                       = "ami-04505e74c0741db8d" # Ubuntu 20 US-EAST-1


  #------------8<------END OPTIONAL VALUES----------->8---------------------

}


