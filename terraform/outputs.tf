output "lh_bucket_bronze" {
  description = "Nome do bucket do lakehouse."
  value       = aws_s3_bucket.sptfy_bronze.id
}

output "lh_bucket_silver" {
  description = "Nome do bucket do lakehouse."
  value       = aws_s3_bucket.sptfy_silver.id
}

output "lh_bucket_gold" {
  description = "Nome do bucket do lakehouse."
  value       = aws_s3_bucket.sptfy_gold.id
}