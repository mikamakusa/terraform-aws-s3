## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.60.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.60.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_accelerate_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_accelerate_configuration) | resource |
| [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_analytics_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_analytics_configuration) | resource |
| [aws_default_tags.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket"></a> [bucket](#input\_bucket) | n/a | <pre>list(object({<br>    id                  = number<br>    bucket              = optional(string)<br>    bucket_prefix       = optional(string)<br>    force_destroy       = optional(bool)<br>    object_lock_enabled = optional(bool)<br>    tags                = optional(map(string))<br>  }))</pre> | `[]` | no |
| <a name="input_bucket_accelerate_configuration"></a> [bucket\_accelerate\_configuration](#input\_bucket\_accelerate\_configuration) | n/a | <pre>list(object({<br>    id                    = number<br>    bucket_id             = any<br>    status                = string<br>    expected_bucket_owner = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_bucket_acl"></a> [bucket\_acl](#input\_bucket\_acl) | n/a | <pre>list(object({<br>    id        = number<br>    bucket_id = any<br>    acl       = optional(string)<br>    access_control_policy = optional(list(object({<br>      grant = list(object({<br>        grantee = list(object({<br>          type          = string<br>          email_address = optional(string)<br>          id            = optional(string)<br>          uri           = optional(string)<br>        }))<br>        permission = string<br>      }))<br>      owner = list(object({<br>        id           = string<br>        display_name = optional(string)<br>      }))<br>    })), [])<br>  }))</pre> | `[]` | no |
| <a name="input_bucket_analytics_configuration"></a> [bucket\_analytics\_configuration](#input\_bucket\_analytics\_configuration) | n/a | <pre>list(object({<br>    id        = number<br>    bucket_id = any<br>    name      = string<br>    filter = optional(list(object({<br>      prefix = optional(string)<br>      tags   = optional(map(string))<br>    })), [])<br>    storage_class_analysis = optional(list(object({<br>      data_export = list(object({<br>        output_schema_version = optional(string)<br>        destination = list(object({<br>          s3_bucket_destination = list(object({<br>            bucket_id         = any<br>            bucket_account_id = optional(string)<br>            format            = optional(string)<br>            prefix            = optional(string)<br>          }))<br>        }))<br>      }))<br>    })), [])<br>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_bucket_accelerate_configuration_id"></a> [s3\_bucket\_accelerate\_configuration\_id](#output\_s3\_bucket\_accelerate\_configuration\_id) | n/a |
| <a name="output_s3_bucket_acl_id"></a> [s3\_bucket\_acl\_id](#output\_s3\_bucket\_acl\_id) | n/a |
| <a name="output_s3_bucket_analytics_configuration_id"></a> [s3\_bucket\_analytics\_configuration\_id](#output\_s3\_bucket\_analytics\_configuration\_id) | n/a |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | n/a |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | n/a |
