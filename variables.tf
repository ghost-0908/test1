variable "location" {
  description = "Azure region in which to create the resources."
  type        = string
  default     = "eastasia"

  validation {
    condition = contains([
      "austriaeast",
      "malaysiawest",
      "koreacentral",
      "uaenorth",
      "eastasia"
    ], var.location)
    error_message = "Location must be one of: austriaeast, malaysiawest, koreacentral, uaenorth, eastasia."
  }
}
