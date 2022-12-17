# Actualizando S3 Bucket Objects

## Pre requisitos

> Si has destruido el entorno recrealo

```bash
cd lab/lc_web_app/
terraform plan -out d4.tfplan
terraform apply "d4.tfplan"
```

## Pasos

Actualizamos `s3.tf`

```diff
## aws_s3_object
+resource "aws_s3_object" "website_content" {
+  for_each = {
+    website = "/website/index.html"
+    logo    = "/website/fruits.png"
+  }
+  bucket = aws_s3_bucket.web_bucket.bucket
+  key    = each.value
+  source = ".${each.value}"
+
+ tags = local.common_tags
+}
- resource "aws_s3_object" "website" {
-   bucket = aws_s3_bucket.web_bucket.bucket
-   key    = "/website/index.html"
-   source = "./website/index.html"
-
-   tags = local.common_tags
- }
-
- resource "aws_s3_object" "graphic" {
-   bucket = aws_s3_bucket.web_bucket.bucket
-   key    = "/website/fruits.png"
-   source = "./website/fruits.png"
-
-   tags = local.common_tags
- }

```


## Clean Up

```bash
terraform destroy
```