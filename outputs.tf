output "s3_bucket_id" {
  value = try(
    aws_s3_bucket.this.*.id
  )
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