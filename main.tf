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
  count  = length(var.bucket) == 0 ? 0 : length(var.bucket_analytics_configuration)
  bucket = try(
    element(aws_s3_bucket.this.*.id, lookup(var.bucket_analytics_configuration[count.index], "bucket_id"))
  )
  name   = lookup(var.bucket_analytics_configuration[count.index], "name")

  dynamic "filter" {
    for_each = try(lookup(var.bucket_analytics_configuration[count.index], "filter") == null ? [] : ["filter"])
    content {
      prefix = lookup(filter.value, "prefix")
      tags   = merge(
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
                  bucket_arn        = try(
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