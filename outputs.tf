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