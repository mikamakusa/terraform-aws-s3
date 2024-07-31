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
  count = length(var.bucket) == 0 ? 0 : length(var.bucket_inventory)
  bucket = try(
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
                  key_id = lookup(sse_kms.value, "key_id")
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

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = length(var.bucket) == 0 ? 0 : length(var.bucket_lifecycle_configuration)
  bucket = try(
    element(aws_s3_bucket.this.*.id, lookup(var.bucket_lifecycle_configuration[count.index], "bucket_id"))
  )
  expected_bucket_owner = try(
    element(aws_s3_bucket_accelerate_configuration.this.*.expected_bucket_owner, lookup(var.bucket_lifecycle_configuration[count.index], "bucket_id"))
  )

  dynamic "rule" {
    for_each = lookup(var.bucket_lifecycle_configuration[count.index], "rule")
    content {
      id     = lookup(rule.value, "id")
      status = lookup(rule.value, "status")

      dynamic "abort_incomplete_multipart_upload" {
        for_each = try(lookup(rule.value, "abort_incomplete_multipart_upload") == null ? [] : ["abort_incomplete_multipart_upload"])
        content {
          days_after_initiation = lookup(abort_incomplete_multipart_upload.value, "days_after_initiation")
        }
      }

      dynamic "expiration" {
        for_each = try(lookup(rule.value, "expiration") == null ? [] : ["expiration"])
        content {
          date                         = lookup(expiration.value, "date")
          days                         = lookup(expiration.value, "days")
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker")
        }
      }

      dynamic "filter" {
        for_each = try(lookup(rule.value, "filter") == null ? [] : ["filter"])
        content {
          object_size_greater_than = lookup(filter.value, "object_size_greater_than")
          object_size_less_than    = lookup(filter.value, "object_size_less_than")
          prefix                   = lookup(filter.value, "prefix")

          dynamic "and" {
            for_each = try(lookup(filter.value, "and") == null ? [] : ["and"])
            content {
              object_size_greater_than = lookup(and.value, "object_size_greater_than")
              object_size_less_than    = lookup(and.value, "object_size_less_than")
              prefix                   = lookup(and.value, "prefix")
              tags = merge(
                var.tags,
                data.aws_default_tags.this.tags,
                lookup(and.value, "tags")
              )
            }
          }

          dynamic "tag" {
            for_each = try(lookup(filter.value, "tag") == null ? [] : ["tag"])
            content {
              key   = lookup(tag.value, "key")
              value = lookup(tag.value, "value")
            }
          }
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = try(lookup(rule.value, "noncurrent_version_expiration") == null ? [] : ["noncurrent_version_expiration"])
        content {
          newer_noncurrent_versions = lookup(noncurrent_version_expiration.value, "newer_noncurrent_versions")
          noncurrent_days           = lookup(noncurrent_version_expiration.value, "noncurrent_days")
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = try(lookup(rule.value, "noncurrent_version_transition") == null ? [] : ["noncurrent_version_transition"])
        content {
          storage_class             = lookup(noncurrent_version_transition.value, "storage_class")
          newer_noncurrent_versions = lookup(noncurrent_version_transition.value, "newer_noncurrent_versions")
          noncurrent_days           = lookup(noncurrent_version_transition.value, "noncurrent_days")
        }
      }

      dynamic "transition" {
        for_each = try(lookup(rule.value, "transition") == null ? [] : ["transition"])
        content {
          storage_class = lookup(transition.value, "storage_class")
          date          = lookup(transition.value, "date")
          days          = lookup(transition.value, "days")
        }
      }
    }
  }
}

resource "aws_s3_bucket_logging" "this" {
  count = length(var.bucket) == 0 ? 0 : length(var.bucket_logging)
  bucket = try(
    element(aws_s3_bucket.this.*.id, lookup(var.bucket_logging[count.index], "bucket_id"))
  )
  target_bucket = try(
    element(aws_s3_bucket.this.*.id, lookup(var.bucket_logging[count.index], "target_bucket_id"))
  )
  target_prefix = lookup(var.bucket_logging[count.index], "target_prefix")
  expected_bucket_owner = try(
    element(aws_s3_bucket_accelerate_configuration.this.*.expected_bucket_owner, lookup(var.bucket_logging[count.index], "expected_bucket_owner_id"))
  )

  dynamic "target_grant" {
    for_each = lookup(var.bucket_logging[count.index], "target_grant") == null ? [] : ["target_grant"]
    content {
      permission = lookup(target_grant.value, "permission")

      dynamic "grantee" {
        for_each = lookup(target_grant.value, "grantee")
        content {
          type          = lookup(grantee.value, "type")
          email_address = lookup(grantee.value, "email_address")
          id            = lookup(grantee.value, "id")
          uri           = lookup(grantee.value, "uri")
        }
      }
    }
  }

  dynamic "target_object_key_format" {
    for_each = lookup(var.bucket_logging[count.index], "target_object_key_format") == null ? [] : ["target_object_key_format"]
    content {
      dynamic "partitioned_prefix" {
        for_each = lookup(target_object_key_format.value, "partitioned_prefix") == null ? [] : ["partitioned_prefix"]
        content {
          partition_date_source = lookup(partitioned_prefix.value, "partition_date_source")
        }
      }
    }
  }
}

resource "aws_s3_bucket_metric" "this" {
  count = length(var.bucket) == 0 ? 0 : length(var.bucket_metric)
  bucket = try(
    element(aws_s3_bucket.this.*.id, lookup(var.bucket_metric[count.index], "bucket_id"))
  )
  name = lookup(var.bucket_metric[count.index], "name")

  dynamic "filter" {
    for_each = lookup(var.bucket_metric[count.index], "filter") == null ? [] : ["filter"]
    content {
      tags = merge(
        data.aws_default_tags.this.tags,
        var.tags,
        lookup(filter.value, "tags")
      )
      prefix = lookup(filter.value, "prefix")
      access_point = try(
        element(var.s3_access_point_arn, lookup(filter.value, "access_point_id"))
      )
    }
  }
}

resource "aws_s3_bucket_notification" "this" {
  count = length(var.bucket) == 0 ? 0 : length(var.bucket_notification)
  bucket = try(
    element(aws_s3_bucket.this.*.id, lookup(var.bucket_notification[count.index], "bucket_id"))
  )
  eventbridge = lookup(var.bucket_notification[count.index], "eventbridge")

  dynamic "lambda_function" {
    for_each = lookup(var.bucket_notification[count.index], "lambda_function") == null ? [] : ["lambda_function"]
    content {
      events        = lookup(lambda_function.value, "events")
      filter_prefix = lookup(lambda_function.value, "filter_prefix")
      filter_suffix = lookup(lambda_function.value, "filter_suffix")
      id            = lookup(lambda_function.value, "id")
      lambda_function_arn = try(
        element(var.lambda_function_arn, lookup(lambda_function.value, "lambda_function_id"))
      )
    }
  }

  dynamic "queue" {
    for_each = lookup(var.bucket_notification[count.index], "queue") == null ? [] : ["queue"]
    content {
      events = lookup(queue.value, "events")
      queue_arn = try(
        element(var.sqs_queue_arn, lookup(queue.value, "queue_id"))
      )
      filter_prefix = lookup(queue.value, "filter_prefix")
      filter_suffix = lookup(queue.value, "filter_suffix")
      id            = lookup(queue.value, "id")
    }
  }

  dynamic "topic" {
    for_each = lookup(var.bucket_notification[count.index], "topic") == null ? [] : ["topic"]
    content {
      topic_arn = try(
        element(var.sns_topic_arn, lookup(topic.value, "topic_id"))
      )
      events        = lookup(topic.value, "events")
      filter_prefix = lookup(topic.value, "filter_prefix")
      filter_suffix = lookup(topic.value, "filter_suffix")
      id            = lookup(topic.value, "id")
    }
  }
}

resource "aws_s3_bucket_object" "this" {
  count = length(var.bucket) == 0 ? 0 : length(var.bucket_object)
  bucket = try(
    element(aws_s3_bucket.this.*.id, lookup(var.bucket_object[count.index], "bucket_id"))
  )
  key                 = lookup(var.bucket_object[count.index], "key")
  acl                 = lookup(var.bucket_object[count.index], "acl")
  bucket_key_enabled  = lookup(var.bucket_object[count.index], "bucket_key_enabled")
  cache_control       = lookup(var.bucket_object[count.index], "cache_control")
  content             = lookup(var.bucket_object[count.index], "content")
  content_base64      = lookup(var.bucket_object[count.index], "content_base64")
  content_disposition = lookup(var.bucket_object[count.index], "content_disposition")
  content_encoding    = lookup(var.bucket_object[count.index], "content_encoding")
  content_language    = lookup(var.bucket_object[count.index], "content_language")
  content_type        = lookup(var.bucket_object[count.index], "content_type")
  etag                = filemd5(join("/", [path.cwd, "etag", lookup(var.bucket_object[count.index], "etag")]))
  force_destroy       = lookup(var.bucket_object[count.index], "force_destroy")
  id                  = lookup(var.bucket_object[count.index], "id")
  kms_key_id = try(
    element(var.bucket_object_kms_key_arn, lookup(var.bucket_object[count.index], "kms_key_id"))
  )
  metadata                      = lookup(var.bucket_object[count.index], "metadata")
  object_lock_legal_hold_status = lookup(var.bucket_object[count.index], "object_lock_legal_hold_status")
  object_lock_mode              = lookup(var.bucket_object[count.index], "object_lock_mode")
  object_lock_retain_until_date = lookup(var.bucket_object[count.index], "object_lock_retain_until_date")
  server_side_encryption        = lookup(var.bucket_object[count.index], "server_side_encryption")
  source                        = lookup(var.bucket_object[count.index], "source")
  source_hash                   = filemd5(join("/", [path.cwd, "etag", lookup(var.bucket_object[count.index], "source_hash")]))
  storage_class                 = lookup(var.bucket_object[count.index], "storage_class")
  tags = merge(
    data.aws_default_tags.this.tags,
    var.tags,
    lookup(var.bucket_object[count.index], "tags")
  )
  website_redirect = lookup(var.bucket_object[count.index], "website_redirect")
}

resource "aws_s3_bucket_object_lock_configuration" "this" {
  count = length(var.bucket) == 0 ? 0 : length(var.bucket_object_lock_configuration)
  bucket                = try(
    element(aws_s3_bucket.this.*.id, lookup(var.bucket_object_lock_configuration[count.index], "bucket_id"))
  )
  expected_bucket_owner = try(
    element(aws_s3_bucket_accelerate_configuration.this.*.expected_bucket_owner, lookup(var.bucket_object_lock_configuration[count.index], "expected_bucket_owner_id"))
  )
  object_lock_enabled   = lookup(var.bucket_object_lock_configuration[count.index], "object_lock_enabled")

  dynamic "rule" {
    for_each = lookup(var.bucket_object_lock_configuration[count.index], "rule") == null ? [] : ["rule"]
    content {
      dynamic "default_retention" {
        for_each = lookup(rule.value, "default_retention")
        content {
          days  = lookup(default_retention.value, "days")
          mode  = lookup(default_retention.value, "mode")
          years = lookup(default_retention.value, "years")
        }
      }
    }
  }
}