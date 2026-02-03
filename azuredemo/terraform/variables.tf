variable "location" {
  type        = string
  description = "Azure region"
  default     = "eastus"
}

variable "vm_size" {
  type        = string
  description = "VM size"
  default     = ""
}
