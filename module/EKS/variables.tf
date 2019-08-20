variable "region" {

}

variable "vpc_id" {

}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)

}
variable "environment" {
  description = "environment name"
}

variable "namespace" {
  description = "Namespace for application"
}

variable "privatesubnet" {
  
}
