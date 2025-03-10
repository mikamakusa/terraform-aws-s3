output "s3_bucket_id" {
  value = try(
    aws_s3_bucket.this.*.id
  )
}

output "bucket_name" {
  value = try(aws_s3_bucket.this.*.bucket)
}

output "s3_bucket_region" {
  value = try(aws_s3_bucket.this.*.region)
}

output "bucket_prefix" {
  value = try(aws_s3_bucket.this.*.bucket_prefix)
}

output "s3_bucket_arn" {
  value = try(aws_s3_bucket.this.*.arn)
}

output "s3_bucket_acl_id" {
  value = try(aws_s3_bucket_acl.this.*.id)
}

output "s3_bucket_accelerate_configuration_id" {
  value = try(aws_s3_bucket_accelerate_configuration.this.*.id)
}

output "s3_bucket_analytics_configuration_id" {
  value = try(aws_s3_bucket_analytics_configuration.this.*.id)
}

output "s3_bucket_cors_configuration_id" {
  value = try(aws_s3_bucket_cors_configuration.this.*.id)
}

output "s3_bucket_cors_rules" {
  value = try(aws_s3_bucket_cors_configuration.this.*.cors_rule)
}

output "bucket_intelligent_tieiring_configuration_id" {
  value = try(
    aws_s3_bucket_intelligent_tiering_configuration.this.*.id
  )
}

output "bucket_inventory_id" {
  value = try(
    aws_s3_bucket_inventory.this.*.id
  )
}

output "bucket_lifecycle_configuration_id" {
  value = try(
    aws_s3_bucket_lifecycle_configuration.this.*.id
  )
}

output "bucket_logging_id" {
  value = try(
    aws_s3_bucket_logging.this.*.id
  )
}

output "bucket_metric_id" {
  value = try(
    aws_s3_bucket_metric.this.*.id
  )
}

output "bucket_notification_id" {
  value = try(
    aws_s3_bucket_notification.this.*.id
  )
}

output "bucket_object_id" {
  value = try(
    aws_s3_bucket_object.this.*.id
  )
}

output "bucket_object_lock_configuration_id" {
  value = try(
    aws_s3_bucket_object_lock_configuration.this.*.id
  )
}

output "bucket_ownership_controls_id" {
  value = try(
    aws_s3_bucket_ownership_controls.this.*.id
  )
}

output "bucket_policy_id" {
  value = try(
    aws_s3_bucket_policy.this.*.id
  )
}

output "bucket_public_access_block_id" {
  value = try(
    aws_s3_bucket_public_access_block.this.*.id
  )
}

output "bucket_replication_configuration_id" {
  value = try(
    aws_s3_bucket_replication_configuration.this.*.id
  )
}

output "bucket_request_payment_configuration_id" {
  value = try(
    aws_s3_bucket_request_payment_configuration.this.*.id
  )
}

output "bucket_server_side_encryption_configuration_id" {
  value = try(
    aws_s3_bucket_server_side_encryption_configuration.this.*.rule
  )
}

output "bucket_versioning_id" {
  value = try(
    aws_s3_bucket_versioning.this.*.id
  )
}

output "bucket_website_configuration_id" {
  value = try(
    aws_s3_bucket_website_configuration.this.*.id
  )
}