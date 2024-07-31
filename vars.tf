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

variable "bucket_cors_configuration" {
  type = list(object({
    id        = number
    bucket_id = any
    cors_rule = list(object({
      allowed_methods = list(string)
      allowed_origins = list(string)
      allowed_headers = optional(list(string))
      expose_headers  = optional(list(string))
      id              = optional(string)
      max_age_seconds = optional(number)
    }))
  }))
  default = []

  validation {
    condition = lenght([
      for a in var.bucket_cors_configuration : true if contains(["GET", "PUT", "HEAD", "POST", "DELETE"], a.cors_rule.allowed_methods)
    ]) == length(var.bucket_cors_configuration)
    error_message = "Valid values are 'GET', 'PUT', 'HEAD', 'POST' and 'DELETE'."
  }
}

variable "bucket_intelligent_tiering_configuration" {
  type = list(object({
    id        = number
    bucket_id = any
    name      = string
    status    = optional(string)
    filter = optional(list(object({
      prefix = optional(string)
      tags   = optional(map(string))
    })), [])
    tiering = list(object({
      access_tier = string
      days        = number
    }))
  }))
  default = []

  validation {
    condition = lenght([
      for a in var.bucket_intelligent_tiering_configuration : true if contains(["Enabled", "Disabled"], a.status)
    ]) == length(var.bucket_intelligent_tiering_configuration)
    error_message = "Valid values are 'Enabled' or 'Disabled'."
  }

  validation {
    condition = lenght([
      for a in var.bucket_intelligent_tiering_configuration : true if contains(["ARCHIVE_ACCESS", "DEEP_ARCHIVE_ACCESS"], a.tiering.access_tier)
    ]) == length(var.bucket_intelligent_tiering_configuration)
    error_message = "Valid values are 'ARCHIVE_ACCESS', 'DEEP_ARCHIVE_ACCESS'."
  }
}

variable "bucket_inventory" {
  type = list(object({
    id                       = number
    bucket_id                = any
    included_object_versions = string
    name                     = string
    enabled                  = optional(bool)
    optional_fields          = optional(set(string))
    destination = list(object({
      bucket = list(object({
        bucket_id  = any
        format     = string
        account_id = optional(string)
        prefix     = optional(string)
        encryption = optional(list(object({
          sse_kms = optional(list(object({
            key_id = string
          })), [])
        })), [])
      }))
    }))
    schedule = list(object({
      frequency = string
    }))
    filter = optional(list(object({
      prefix = optional(string)
    })))
  }))
  default = []

  validation {
    condition = lenght([
      for a in var.bucket_inventory : true if contains(["Daily", "Weekly"], a.schedule.frequency)
    ]) == length(var.bucket_inventory)
    error_message = "Valid values are 'Daily' or 'Weekly'."
  }

  validation {
    condition = length([
      for b in var.bucket_inventory : true if contains(["All", "Current"], b.included_object_versions)
    ]) == length(var.bucket_inventory)
    error_message = "Valid values are 'All' or 'Current'."
  }

  validation {
    condition = length([
      for c in var.bucket_inventory : true if contains(["CSV", "ORC", "PARQUET"], c.destination.bucket.format)
    ]) == length(var.bucket_inventory)
    error_message = "Valid values are 'CSV', 'ORC' or 'PARQUET'."
  }
}