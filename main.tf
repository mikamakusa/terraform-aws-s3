resource "aws_s3_bucket" "this" {
  count               = length(var.bucket)
  bucket              = lookup(var.bucket[count.index], "bucket")
  bucket_prefix       = lookup(var.bucket[count.index], "bucket_prefix")
  force_destroy       = lookup(var.bucket[count.index], "force_destroy")
  object_lock_enabled = lookup(var.bucket[count.index], "object_lock_enabled")
  tags = merge(
    var.tags,
    data.aws_default_tags.this.tags,
    lookup(var.bucket[count.index], "tags")
  )
}

resource "aws_s3_bucket_accelerate_configuration" "this" {
  count = length(var.bucket) == 0 ? 0 : length(var.bucket_accelerate_configuration)
  bucket = try(
    element(aws_s3_bucket.this.*.id, lookup(var.bucket_accelerate_configuration[count.index], "bucket_id"))
  )
  status                = lookup(var.bucket_accelerate_configuration[count.index], "status")
  expected_bucket_owner = lookup(var.bucket_accelerate_configuration[count.index], "expected_bucket_owner")
}

resource "aws_s3_bucket_acl" "this" {
  count = length(var.bucket) == 0 ? 0 : length(var.bucket_acl)
  bucket = try(
    element(aws_s3_bucket_accelerate_configuration.this.*.bucket, lookup(var.bucket_acl[count.index], "bucket_id"))
  )
  acl = lookup(var.bucket_acl[count.index], "acl")
  expected_bucket_owner = try(
    element(aws_s3_bucket_accelerate_configuration.this.*.expected_bucket_owner, lookup(var.bucket_acl[count.index], "bucket_id"))
  )

  dynamic "access_control_policy" {
    for_each = try(lookup(var.bucket_acl[count.index], "access_control_policy") == null ? [] : ["access_control_policy"])
    content {
      dynamic "grant" {
        for_each = lookup(access_control_policy.value, "grant")
        content {
          permission = lookup(grant.value, "permission")
          dynamic "grantee" {
            for_each = lookup(grant.value, "grantee")
            content {
              type          = lookup(grantee.value, "type")
              email_address = lookup(grantee.value, "email-address")
              id            = lookup(grantee.value, "id")
              uri           = lookup(grantee.value, "uri")
            }
          }
        }
      }
      dynamic "owner" {
        for_each = lookup(access_control_policy.value, "owner")
        content {
          id           = lookup(owner.value, "id")
          display_name = lookup(owner.value, "display_name")
        }
      }
    }
  }
}

resource "aws_s3_bucket_analytics_configuration" "this" {
  count = length(var.bucket) == 0 ? 0 : length(var.bucket_analytics_configuration)
  bucket = try(
    element(aws_s3_bucket.this.*.id, lookup(var.bucket_analytics_configuration[count.index], "bucket_id"))
  )
  name = lookup(var.bucket_analytics_configuration[count.index], "name")

  dynamic "filter" {
    for_each = try(lookup(var.bucket_analytics_configuration[count.index], "filter") == null ? [] : ["filter"])
    content {
      prefix = lookup(filter.value, "prefix")
      tags = merge(
        lookup(filter.value, "tags"),
        var.tags,
        data.aws_default_tags.this.tags
      )
    }
  }

  dynamic "storage_class_analysis" {
    for_each = try(lookup(var.bucket_analytics_configuration[count.index], "storage_class_analysis") == null ? [] : ["storage_class_analysis"])
    content {
      dynamic "data_export" {
        for_each = lookup(storage_class_analysis.value, "data_export")
        content {
          output_schema_version = lookup(data_export.value, "output_schema_version")

          dynamic "destination" {
            for_each = lookup(data_export.value, "destination")
            content {
              dynamic "s3_bucket_destination" {
                for_each = lookup(destination.value, "s3_bucket_destination")
                content {
                  bucket_arn = try(
                    element(aws_s3_bucket.this.*.arn, lookup(s3_bucket_destination.value, "bucket_id"))
                  )
                  bucket_account_id = lookup(s3_bucket_destination.value, "bucket_account_id")
                  format            = lookup(s3_bucket_destination.value, "format")
                  prefix            = lookup(s3_bucket_destination.value, "prefix")
                }
              }
            }
          }
        }
      }
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "this" {
  count = length(var.bucket) == 0 ? 0 : length(var.bucket_cors_configuration)
  bucket = try(
    element(aws_s3_bucket_accelerate_configuration.this.*.bucket, lookup(var.bucket_cors_configuration[count.index], "bucket_id"))
  )
  expected_bucket_owner = try(
    element(aws_s3_bucket_accelerate_configuration.this.*.expected_bucket_owner, lookup(var.bucket_cors_configuration[count.index], "bucket_id"))
  )

  dynamic "cors_rule" {
    for_each = lookup(var.bucket_cors_configuration[count.index], "cors_rule")
    content {
      allowed_methods = lookup(cors_rule.value, "allowed_methods")
      allowed_origins = lookup(cors_rule.value, "allowed_origins")
      allowed_headers = lookup(cors_rule.value, "allowed_headers")
      expose_headers  = lookup(cors_rule.value, "expose_headers")
      id              = lookup(cors_rule.value, "id")
      max_age_seconds = lookup(cors_rule.value, "max_age_seconds")
    }
  }
}

resource "aws_s3_bucket_intelligent_tiering_configuration" "this" {
  count = length(var.bucket) == 0 ? 0 : length(var.bucket_intelligent_tiering_configuration)
  bucket = try(
    element(aws_s3_bucket.this.*.id, lookup(var.bucket_intelligent_tiering_configuration[count.index], "bucket_id"))
  )
  name   = lookup(var.bucket_intelligent_tiering_configuration[count.index], "name")
  status = lookup(var.bucket_intelligent_tiering_configuration[count.index], "status")

  dynamic "filter" {
    for_each = try(
      lookup(var.bucket_intelligent_tiering_configuration[count.index], "filter") == null ? [] : ["filter"]
    )
    content {
      prefix = lookup(filter.value, "prefix")
      tags = merge(
        var.tags,
        data.aws_default_tags.this.tags,
        lookup(filter.value, "tags")
      )
    }
  }

  dynamic "tiering" {
    for_each = lookup(var.bucket_intelligent_tiering_configuration[count.index], "tiering")
    content {
      access_tier = lookup(tiering.value, "access_tier")
      days        = lookup(tiering.value, "days")
    }
  }
}

resource "aws_s3_bucket_inventory" "this" {
  count                    = length(var.bucket) == 0 ? 0 : length(var.bucket_inventory)
  bucket                   = try(
    element(aws_s3_bucket.this.*.id, lookup(var.bucket_inventory[count.index], "bucket_id"))
  )
  included_object_versions = lookup(var.bucket_inventory[count.index], "included_object_versions")
  name                     = lookup(var.bucket_inventory[count.index], "name")
  enabled                  = lookup(var.bucket_inventory[count.index], "enabled")
  optional_fields          = lookup(var.bucket_inventory[count.index], "optional_fields")

  dynamic "destination" {
    for_each = lookup(var.bucket_inventory[count.index], "destination")
    content {
      dynamic "bucket" {
        for_each = lookup(destination.value, "bucket")
        content {
          bucket_arn = try(
            element(aws_s3_bucket.this.*.arn, lookup(bucket.value, "bucket_id"))
          )
          format     = lookup(bucket.value, "format")
          account_id = lookup(bucket.value, "account_id")
          prefix     = lookup(bucket.value, "prefix")

          dynamic "encryption" {
            for_each = lookup(bucket.value, "encryption") == null ? [] : ["encrpytion"]
            content {
              dynamic "sse_kms" {
                for_each = lookup(encryption.value, "sse_kms") == null ? [] : ["sse_kms"]
                content {
                  key_id = ""
                }
              }
            }
          }
        }
      }
    }
  }

  dynamic "schedule" {
    for_each = lookup(var.bucket_inventory[count.index], "schedule")
    content {
      frequency = lookup(schedule.value, "frequency")
    }
  }

  dynamic "filter" {
    for_each = lookup(var.bucket_inventory[count.index], "filter") == null ? [] : ["filter"]
    content {
      prefix = lookup(filter.value, "prefix")
    }
  }
}