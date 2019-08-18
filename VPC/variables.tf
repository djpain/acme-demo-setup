variable "namespace" {
  type        = "string"
  description = "Namespace"
}

variable "stage" {
  type        = "string"
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "name" {
  type        = "string"
  description = "Name (e.g. `app`)"
}

variable "cidr_block" {
  type        = "string"
  default     = "10.0.0.0/16"
  description = "Base CIDR block which is divided into subnet CIDR blocks (e.g. `10.0.0.0/16`)"
}

variable "igw_id" {
  type        = "string"
  description = "Internet Gateway ID that is used as a default route when creating public subnets (e.g. `igw-9c26a123`)"
  default     = ""
}

variable "az" {
  type        = "list"
  description = "list of AZ available "
  default     = ["ap-southeast-2a","ap-southeast-2b","ap-southeast-2c"]
}
