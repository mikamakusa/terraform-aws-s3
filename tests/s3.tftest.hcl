run "setup_tests" {
  module {
    source = "./tests/setup"
  }
}

run "create_s3_bucket" {
  command = [plan,apply]

  variables {
    tags = {
      cloud     = true
      terraform = true
    }
    bucket = [
      {
        id                  = 0
        bucket              = "test-bucket"
        force_destroy       = false
        object_lock_enabled = false
        tags = {
          Name        = "My bucket"
          Environment = "Dev"
        }
      },
      {
        id      = 1
        bucket  = "my-tf-log-bucket"
      }
    ]
    bucket_accelerate_configuration = [
      {
        id        = 0
        bucket_id = 0
        status    = "Enabled"
      }
    ]
    bucket_acl = [
      {
        id        = 0
        bucket_id = 0
        acl       = "public-read"
      },
      {
        id        = 1
        bucket_id = 1
        acl       = "log-delivery-write"
      }
    ]
    bucket_analytics_configuratio = [
      {
        id        = 0
        bucket_id = 0
        name      = "EntireBucket"
        storage_class_analysis = [
          {
            data_export = [
              {
                destination = [
                  {
                    s3_bucket_destination = [
                      {
                        bucket_arn = aws_s3_bucket.analytics.arn
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
    ]
    bucket_cors_coonfiguration = [
      {
        id        = 0
        bucket_id = 0
        cors_rule = [
          {
            allowed_headers = ["*"]
            allowed_methods = ["PUT", "POST"]
            allowed_origins = ["https://s3-website-test.hashicorp.com"]
            expose_headers = ["ETag"]
            max_age_seconds = 3000
          }
        ]
      }
    ]
    bucket_intelligent_tiering_configuration = [
      {
        id        = 0
        bucket_id = 0
        name      = "EntireBucket"
        tiering = [
          {
            access_tier = "DEEP_ARCHIVE_ACCESS"
            days        = 180
          },
          {
            access_tier = "ARCHIVE_ACCESS"
            days        = 125
          }
        ]
      }
    ]
    bucket_inventory = [
      {
        id                        = 0
        bucket_id                 = 0
        name                      = "DocumentsWeekly"
        included_object_versions  = "All"
        schedule = [
          {
            frequency = "Daily"
          }
        ]
        destination = [
          {
            bucket = [
              {
                format     = "ORC"
                bucket_arn = aws_s3_bucket.inventory.arn
                prefix     = "inventory"
              }
            ]
          }
        ]
      }
    ]
    bucket_logging = [
      {
        id                = 0
        bucket_id         = 0
        target_bucket_id  = 1
        target_prefix     = "log/"
      }
    ]
    bucket_metric = [
      {
        id        = 0
        bucket_id = 0
        name      = "ImportantBlueDocuments"
        filter = [
          {
            access_point_id = aws_s3_access_point.example-access-point.arn
          }
        ]
      }
    ]
    bucket_object = [
      {
        id                     = 0
        key                    = "someobject"
        bucket_id              = 0
        source                 = "index.html"
        server_side_encryption = "AES256"
      }
    ]
    bucket_object_lock_configuration = [
      {
        id        = 0
        bucket_id = 0
        rule = [
          {
            default_retention = [
              {
                mode = "COMPLIANCE"
                days = 5
              }
            ]
          }
        ]
      }
    ]
  }
}