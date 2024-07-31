variable "tags" {
  type    = map(string)
  default = {}
}

variable "s3_access_point_arn" {
  type    = string
  default = null
}

variable "sqs_queue_arn" {
  type    = string
  default = null
}

variable "lambda_function_arn" {
  type    = string
  default = null
}

variable "sns_topic_arn" {
  type    = string
  default = null
}

variable "bucket_object_kms_key_arn" {
  type    = string
  default = null
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

variable "bucket_lifecycle_configuration" {
  type = list(object({
    id                    = number
    bucket_id             = any
    expected_bucket_owner = optional(string)
    rule = list(object({
      id     = string
      status = string
      abort_incomplete_multipart_upload = optional(list(object({
        days_after_initiation = optional(number)
      })), [])
      expiration = optional(list(object({
        date                         = optional(string)
        days                         = optional(number)
        expired_object_delete_marker = optional(bool)
      })), [])
      filter = optional(list(object({
        object_size_greater_than = optional(string)
        object_size_less_than    = optional(string)
        prefix                   = optional(string)
        and = optional(list(object({
          object_size_greater_than = optional(number)
          object_size_less_than    = optional(number)
          prefix                   = optional(string)
          tags                     = optional(map(string))
        })), [])
        tag = optional(list(object({
          key   = string
          value = string
        })), [])
      })), [])
      noncurrent_version_expiration = optional(list(object({
        newer_noncurrent_versions = optional(string)
        noncurrent_days           = optional(number)
      })), [])
      noncurrent_version_transition = optional(list(object({
        storage_class             = string
        newer_noncurrent_versions = optional(string)
        noncurrent_days           = optional(number)
      })), [])
      transition = optional(list(object({
        storage_class = string
        date          = optional(string)
        days          = optional(number)
      })), [])
    }))
  }))
  default = []

  validation {
    condition = length([
      for a in var.bucket_lifecycle_configuration : true if contains(["GLACIER", "STANDARD_IA", "ONEZONE_IA", "INTELLIGENT_TIERING", "DEEP_ARCHIVE", "GLACIER_IR"], a.rule.transition.storage_class)
    ]) == length(var.bucket_lifecycle_configuration)
    error_message = "Valid values are GLACIER, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, DEEP_ARCHIVE or GLACIER_IR."
  }

  validation {
    condition = length([
      for b in var.bucket_lifecycle_configuration : true if contains(["GLACIER", "STANDARD_IA", "ONEZONE_IA", "INTELLIGENT_TIERING", "DEEP_ARCHIVE", "GLACIER_IR"], b.rule.noncurrent_version_expiration.storage_class)
    ]) == length(var.bucket_lifecycle_configuration)
    error_message = "Valid values are GLACIER, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, DEEP_ARCHIVE or GLACIER_IR."
  }
}

variable "bucket_logging" {
  type = list(object({
    id                       = number
    bucket_id                = any
    target_bucket_id         = any
    target_prefix            = string
    expected_bucket_owner_id = any
    target_grant = optional(list(object({
      permission = string
      grantee = list(object({
        type          = string
        email_address = optional(string)
        id            = optional(string)
        uri           = optional(string)
      }))
    })), [])
    target_object_key_format = optional(list(object({
      partitioned_prefix = optional(list(object({
        partition_date_source = any
      })), [])
    })), [])
  }))
  default = []

  validation {
    condition = length([
      for a in var.bucket_logging : true if contains(["FULL_CONTROL", "READ", "WRITE"], a.target_grant.permission)
    ]) == length(var.bucket_logging)
    error_message = "Valid values are FULL_CONTROL, READ or WRITE."
  }

  validation {
    condition = length([
      for b in var.bucket_logging : true if contains(["CanonicalUser", "AmazonCustomerByEmail", "Group"], b.target_grant.grantee.type)
    ]) == length(var.bucket_logging)
    error_message = "Valid values are CanonicalUser, AmazonCustomerByEmail or Group."
  }

  validation {
    condition = length([
      for c in var.bucket_logging : true if contains(["EventTime", "DeliveryTime"], c.target_object_key_format.partitioned_prefix.partition_date_source)
    ]) == length(var.bucket_logging)
    error_message = "Valid values are EventTime or DeliveryTime."
  }
}

variable "bucket_metric" {
  type = list(object({
    id        = number
    bucket_id = any
    name      = string
    filter = optional(list(object({
      tags            = optional(map(string))
      prefix          = optional(string)
      access_point_id = optional(any)
    })))
  }))
  default = []
}

variable "bucket_notification" {
  type = list(object({
    id          = number
    bucket_id   = any
    eventbridge = optional(bool)
    lambda_function = optional(list(object({
      events             = set(string)
      filter_prefix      = optional(string)
      filter_suffix      = optional(string)
      id                 = optional(string)
      lambda_function_id = any
    })))
    queue = optional(list(object({
      events        = set(string)
      queue_id      = any
      filter_prefix = optional(string)
      filter_suffix = optional(string)
      id            = optional(string)
    })))
    topic = optional(list(object({
      topic_id      = any
      events        = set(string)
      filter_prefix = optional(string)
      filter_suffix = optional(string)
      id            = optional(string)
    })))
  }))
  default = []
}

variable "bucket_object" {
  type = list(object({
    id                            = number
    bucket_id                     = any
    key                           = string
    acl                           = optional(string)
    bucket_key_enabled            = optional(bool)
    cache_control                 = optional(string)
    content                       = optional(string)
    content_base64                = optional(string)
    content_disposition           = optional(string)
    content_encoding              = optional(string)
    content_language              = optional(string)
    content_type                  = optional(string)
    etag                          = optional(string)
    force_destroy                 = optional(bool)
    id                            = optional(string)
    kms_key_id                    = optional(any)
    metadata                      = optional(map(string))
    object_lock_legal_hold_status = optional(string)
    object_lock_mode              = optional(string)
    object_lock_retain_until_date = optional(string)
    server_side_encryption        = optional(string)
    source                        = optional(string)
    source_hash                   = optional(string)
    storage_class                 = optional(string)
    tags                          = optional(map(string))
    website_redirect              = optional(string)
  }))
  default = []

  validation {
    condition = length([
      for a in var.bucket_object : true if contains(["private", "public-read", "public-read-write", "aws-exec-read", "authenticated-read", "bucket-owner-read", "bucket-owner-full-control"], a.acl)
    ]) == length(var.bucket_object)
    error_message = "Valid values are private, public-read, public-read-write, aws-exec-read, authenticated-read, bucket-owner-read, and bucket-owner-full-control."
  }

  validation {
    condition = length([
      for b in var.bucket_object : true if contains(["ON", "OFF"], b.object_lock_legal_hold_status)
    ]) == length(var.bucket_object)
    error_message = "Valid values are ON and OFF."
  }

  validation {
    condition = length([
      for c in var.bucket_object : true if contains(["GOVERNANCE", "COMPLIANCE"], c.object_lock_mode)
    ]) == length(var.bucket_object)
    error_message = "Valid values are GOVERNANCE and COMPLIANCE."
  }

  validation {
    condition = length([
      for d in var.bucket_object : true if contains(["AES256", "aws:kms"], d.server_side_encryption)
    ]) == length(var.bucket_object)
    error_message = "valid values are AES256 and aws:kms."
  }
}

variable "bucket_object_lock_configuration" {
  type = list(object({
    id                       = number
    bucket_id                = any
    expected_bucket_owner_id = optional(any)
    object_lock_enabled      = optional(string)
    rule = optional(list(object({
      default_retention = list(object({
        days  = optional(number)
        mode  = optional(string)
        years = optional(number)
      }))
    })))
  }))
  default = []

  validation {
    condition = length([
      for a in var.bucket_object_lock_configuration : true if contains(["GOVERNANCE", "COMPLIANCE"], a.rule.default_retention.mode)
    ]) == length(var.bucket_object_lock_configuration)
    error_message = "Valid values are GOVERNANCE and COMPLIANCE."
  }
}