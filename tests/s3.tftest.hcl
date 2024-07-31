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
  }
}