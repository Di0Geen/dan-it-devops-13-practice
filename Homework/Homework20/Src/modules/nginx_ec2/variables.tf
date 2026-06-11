variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "list_of_open_ports" {
  description = "List of open ports"
  type        = list(number)
}