# resource "aws_s3_bucket" "efsbucket" {
#   bucket        = "my-efs-bucket"
#   acl           = "private"
#   force_destroy = true
# }

# resource "aws_s3_bucket_public_access_block" "s3block" {
#   bucket = aws_s3_bucket.efsbucket.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# resource "aws_s3_bucket_object" "object" {
#   acl          = "public-read"
#   depends_on   = [aws_s3_bucket.my_bucket]
#   bucket       = aws_s3_bucket.efsbucket.id
#   key          = "index.html"
#   content_type = "text/html"
#   source       = "C:/Users/HP/Documents/GIT/Efs-infra/index.html"
# }

# locals {
#   s3_origin_id = aws_s3_bucket.efsbucket.id
# }


# # Creating cloudFront 
# resource "aws_cloudfront_distribution" "efscloudfront" {
#   enabled             = true
#   default_root_object = "index.html"

#   origin {
#     domain_name = aws_s3_bucket.efsbucket.bucket_regional_domain_name
#     origin_id   = aws_s3_bucket.efsbucket.bucket_regional_domain_name

#     s3_origin_config {
#       origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
#     }
#   }

#   default_cache_behavior {
#     allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
#     cached_methods         = ["GET", "HEAD", "OPTIONS"]
#     target_origin_id       = aws_s3_bucket.efsbucket.bucket_regional_domain_name
#     viewer_protocol_policy = "redirect-to-https"

#     forwarded_values {
#       headers      = []
#       query_string = true

#       cookies {
#         forward = "all"
#       }
#     }
#   }

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }

#   viewer_certificate {
#     cloudfront_default_certificate = true
#   }
# }

# // Origin Access Identity(sharing private cintent via cloudfront)
# resource "aws_cloudfront_origin_access_identity" "oai" {
#   comment = "OAI for efsbucket"
# }


# // bucket policy that allows communication between cloudfront and s3 using OAI
# resource "aws_s3_bucket_policy" "s3-policy" {
#   bucket = aws_s3_bucket.efsbucket.id
#   policy = data.aws_iam_policy_document.s3policy.json
# }

# # Retrieve CloudFront Domain 
# resource "null_resource" "CloudFront_Domain" {
#   depends_on = [aws_cloudfront_distribution.s3_distribution]

#   provisioner "local-exec" {
#     command = "echo ${aws_cloudfront_distribution.s3_distribution.domain_name} > CloudFrontURL.txt"
#   }
# }