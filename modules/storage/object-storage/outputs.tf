output "bucket_name" {
  value = ncloud_objectstorage_bucket.this.bucket_name
}

# 전체 리소스 raw dump (디버깅용)
output "bucket_raw" {
  value = ncloud_objectstorage_bucket.this
}
