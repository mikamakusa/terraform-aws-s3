variable "tags" {
  type    = map(string)
  default = {}
}

variable "bucket" {
  type = list(object({
    id                  = number
    bucket              = optional(string)
    bucket_prefix       = optional(string)
    force_destroy       = optional(bool)
    object_lock_enabled = optional(bool)
    tags                = optional(map(string))
  }))
  default = []
}

variable "bucket_accelerate_configuration" {
  type = list(object({
    id                    = number
    bucket_id             = any
    status                = string
    expected_bucket_owner = optional(string)
  }))
  default = []

  validation {
    condition = length([
      for i in var.bucket_accelerate_configuration : true if contains(["Enabled", "Suspended"], i.status)
    ]) == length(var.bucket_accelerate_configuration)
    error_message = "Valid values are 'Enabled' or 'Suspended'."
  }
}

variable "bucket_acl" {
  type = list(object({
    id        = number
    bucket_id = any
    acl       = optional(string)
    access_control_policy = optional(list(object({
      grant = list(object({
        grantee = list(object({
          type          = string
          email_address = optional(string)
          id            = optional(string)
          uri           = optional(string)
        }))
        permission = string
      }))
      owner = list(object({
        id           = string
        display_name = optional(string)
      }))
    })), [])
  }))
  default = []
}

variable "bucket_analytics_configuration" {
  type = list(object({
    id        = number
    bucket_id = any
    name      = string
    filter = optional(list(object({
      prefix = optional(string)
      tags   = optional(map(string))
    })), [])
    storage_class_analysis = optional(list(object({
      data_export = list(object({
        output_schema_version = optional(string)
        destination = list(object({
          s3_bucket_destination = list(object({
            bucket_id         = any
            bucket_account_id = optional(string)
            format            = optional(string)
            prefix            = optional(string)
          }))
        }))
      }))
    })), [])
  }))
  default = []
}