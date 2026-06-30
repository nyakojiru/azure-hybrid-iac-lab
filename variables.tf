variable "prefix" {
  description = "Short name prefix for all resources (lowercase, 3-10 chars)."
  type        = string
  default     = "hybridlab"

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{2,9}$", var.prefix))
    error_message = "prefix must be 3-10 lowercase alphanumeric chars, starting with a letter."
  }
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "westeurope"
}

variable "node_count" {
  description = "Number of nodes in the AKS system node pool."
  type        = number
  default     = 1
}

variable "node_vm_size" {
  description = "VM size for the AKS system node pool."
  type        = string
  default     = "Standard_B2s" # cheap; fine for a lab
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default = {
    project = "azure-hybrid-iac-lab"
    owner   = "patriciollorens"
    managed = "terraform"
  }
}
