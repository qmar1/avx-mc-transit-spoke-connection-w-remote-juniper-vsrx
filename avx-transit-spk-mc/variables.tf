variable "controller_ip" {
  type = string

}

variable "ctrl_user_name" {

  type = string
}

variable "ctrl_psswd" {
  type = string
}


variable "aws_xt_local_as_num" {
  default     = 65500
  type        = string
  description = "local as number for AWS xt"
}

variable "az_xt_local_as_num" {
  default     = 65001
  type        = string
  description = "local as number for az xt"
}

variable "gcp_xt_local_as_num" {
  default     = 65002
  type        = string
  description = "local as number for gcp xt"
}

variable "oci_xt_local_as_num" {
  default     = 65003
  type        = string
  description = "local as number for oci xt"
}

variable "aws_sp_local_as_num" {
  default     = 65010
  type        = string
  description = "local as number for AWS spoke"
}
