# object storage bucket 생성
resource "ncloud_objectstorage_bucket" "this" {
  bucket_name = var.bucket_name
}
