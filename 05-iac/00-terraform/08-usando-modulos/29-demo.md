# Adding the S3 Module

Okay, here is my updated solution. 

* Update `s3.tf`

```ini
# diff
module "web_app_s3" {
  source = "./modules/lc-web-app-s3"

  bucket_name             = local.s3_bucket_name
  elb_service_account_arn = data.aws_elb_service_account.root.arn
  common_tags             = local.common_tags
}
# diff
resource "aws_s3_object" "website_content" {
  for_each = {
    website = "/website/index.html"
    logo    = "/website/fruits.png"
  }
  bucket = aws_s3_bucket.web_bucket.bucket
  key    = each.value
  source = ".${each.value}"

}

```

We're creating a module with the name_label web_app_s3. The source will be the current working directory /modules/globo‑web‑app‑s3. We have to give it three input variable values, bucket_name set to the local.s3_bucket_name, elb_service_account set to the elb_service_account data source, and common_tags set to local.common_tags. Now that we've updated to use a module, we're going to have to update any references to the bucket or the instance_profile with the output values from this module. For instance, our bucket argument in the aws_s3_bucket object should be updated to module.web_app_s3.web_bucket.id. 

```diff
resource "aws_s3_object" "website_content" {
  for_each = {
    website = "/website/index.html"
    logo    = "/website/fruits.png"
  }
- bucket = aws_s3_bucket.web_bucket.bucket
+ bucket = module.web_app_s3.web_bucket.id
  key    = each.value
  source = ".${each.value}"

}
```

My challenge to you now is to update any other references to the bucket or the instance_profile in our configuration to use the proper output value from our S3 module. Go ahead and do that now, and then we'll review my updated configuration when we come back. 

* Update `loadbalancer.tf`

```diff
resource "aws_lb" "nginx" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  access_logs {
-   bucket  = aws_s3_bucket.web_bucket.bucket
+   bucket  = module.web_app_s3.web_bucket.id
    prefix  = "alb-logs"
    enabled = true
  }

  tags = local.common_tags
}
```

* Update `instances.tf` 

```diff
resource "aws_instance" "nginx" {
  count         = var.instance_count
  ami           = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type = var.aws_instance_type
  key_name      = "aws_key_paris"
  subnet_id     = module.vpc.public_subnets[(count.index % var.vpc_subnet_count)]

  vpc_security_group_ids = [
    aws_security_group.nginx-sg.id
  ]
- iam_instance_profile = aws_iam_instance_profile.nginx_profile.name
+ iam_instance_profile = module.web_app_s3.instance_profile.name
  depends_on = [
-   aws_iam_role_policy.allow_s3_all
+   module.web_app_s3
    aws_s3_object.website_content
  ]

  user_data = templatefile("${path.module}/startup_script.tpl", {
-   s3_bucket_name = aws_s3_bucket.web_bucket.id
+   s3_bucket_name = module.web_app_s3.web_bucket.id
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nginx-${count.index}"
  })
}

```

Okay, we're back in the loadbalancer file. I simply updated the access_logs argument to use the S3 bucket created by our module. Over in instances, the iam_instance_profile has been updated to use the instance_profile output value, .name. We had to update the depends_on, because it was referencing the iam_role, but that's not available to us anymore, so instead we just make it dependent on the module itself. And then in the templatefile function we have to update the s3_bucket_name to be the web_bucket output value and the .id attribute. While we're looking at the instance configuration, one thing I want to point out is the configuration for the subnet_id. At the end of the module expression, I have removed the .id attribute, and that is because what's returned by the module is actually a list of public subnets and not the public_subnets object itself, which would have the id attribute. That's going to do it for all the updates to our configuration. Go ahead and save those updates. The next step is to get those updates deployed.