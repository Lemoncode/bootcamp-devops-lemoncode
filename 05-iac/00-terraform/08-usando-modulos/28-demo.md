# Creating the S3 Module

Let's create the S3 module inside of the globo_web_app directory. We'll start by adding a directory called modules, just in case we want to add any future modules to our configuration. Within that modules directory, let's add a subdirectory for our S3 module, and we'll name the directory, globo‑web‑app‑s3, so that's pretty descriptive of what this module is intended for. 

```bash
cd ./lc_web_app
mkdir -p modules/lc-web-app-s3
```

Within that directory we'll create three files. We'll start by creating the **variables.tf**, followed by a **main.tf** file to hold all of our resources, and then an **outputs.tf** file for our output values. 

```bash
touch ./modules/lc-web-app-s3/variables.tf;
touch ./modules/lc-web-app-s3/main.tf;
touch ./modules/lc-web-app-s3/outputs.tf;
```

Within the variables file, I'm going to add some comments here for variables we want to create. My challenge to you is to create these three variables, the bucket name, the ELB service account, and the common tags to pass to this module. Go ahead and try that now, and when we come back you can see my updated solution. 

* Update variables.tf

```ini
# Bucket Name
variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket to create"
}

# ELB service account arn
variable "elb_service_account_arn" {
  type        = string
  description = "ARN of ELB service account"
}

# Common tags
variable "common_tags" {
  type        = map(string)
  description = "Map of tags to be applied to all resources"
  default     = {}
}

```

Okay, here is my solution. I've got a variable named bucket_name that's of type string; a variable called elb_service_account_arn, which is also of type string; and then a variable called common_tags, which is of type map with strings as the values for the map. And I actually set a default for the common_tags in case someone using this module doesn't submit a list of common tags to use in the configuration. 

Next up, we will add our resources to the main.tf file. So let's scroll down and open up the s3.tf file. We are going to copy all the resources in here except for the S3 bucket objects. Those will still be created in part of our main configuration. 

First, I will grab the S3 bucket resource, remove that from the s3.tf file, and paste it into the `main.tf` file. 

* Copy from `s3.tf` everything unless `aws_s3_object`

```ini
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

* Update `main.tf`

```ini
# aws_s3_bucket
resource "aws_s3_bucket" "web_bucket" {
  bucket        = local.s3_bucket_name
  force_destroy = true

  tags = local.common_tags
}

# aws_s3_bucket_policy
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.web_bucket.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_elb_service_account.root.arn}"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${local.s3_bucket_name}/alb-logs/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${local.s3_bucket_name}/alb-logs/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::${local.s3_bucket_name}"
    }
  ]
}
  POLICY
}

# aws_iam_role
resource "aws_iam_role" "allow_nginx_s3" {
  name = "allow_nginx_s3"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
  EOF

  tags = local.common_tags
}

# aws_iam_role_policy
resource "aws_iam_role_policy" "allow_s3_all" {
  name = "allow_s3_all"
  role = aws_iam_role.allow_nginx_s3.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${local.s3_bucket_name}",
        "arn:aws:s3:::${local.s3_bucket_name}/*"
      ]
    }
  ]
}
  EOF
}

# aws_iam_instance_profile
resource "aws_iam_instance_profile" "nginx_profile" {
  name = "nginx_profile"
  role = aws_iam_role.allow_nginx_s3.name

  tags = local.common_tags
}

```

Next, I will grab all of the IAM resources below the bucket object resource and paste those into the main.tf file. Let's go ahead and save the s3.tf file. 


And now back in the main.tf file, my challenge for you is to update the references here to use the input variables for all of the resources. Go ahead and try that now, and when we come back we can review my updated solution. 

* Update `main.tf`

```diff
resource "aws_s3_bucket" "web_bucket" {
- bucket        = local.s3_bucket_name
+ bucket        = var.bucket_name
  force_destroy = true

- tags = local.common_tags
+ tags = var.common_tags
}

```

```ini
# aws_s3_bucket_policy
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.web_bucket.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${var.elb_service_account_arn}" # diff
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.bucket_name}/alb-logs/*" # diff
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.bucket_name}/alb-logs/*", # diff
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::${var.bucket_name}" # diff
    }
  ]
}
  POLICY
}

```

```diff
# aws_iam_role
resource "aws_iam_role" "allow_nginx_s3" {
- name = "allow_nginx_s3"
+ name = "${var.bucket_name}-allow_nginx_s3"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
  EOF

- tags = local.common_tags
+ tags = var.common_tags
}

# aws_iam_role_policy
resource "aws_iam_role_policy" "allow_s3_all" {
- name = "allow_s3_all"
+ name = "${var.bucket_name}-allow_s3_all"
  role = aws_iam_role.allow_nginx_s3.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": [
-       "arn:aws:s3:::${local.s3_bucket_name}",
+       "arn:aws:s3:::${var.bucket_name}",
-       "arn:aws:s3:::${local.s3_bucket_name}/*"
+       "arn:aws:s3:::${var.bucket_name}/*"
      ]
    }
  ]
}
  EOF
}

# aws_iam_instance_profile
resource "aws_iam_instance_profile" "nginx_profile" {
- name = "nginx_profile"
+ name = "${var.bucket_name}-nginx_profile"
  role = aws_iam_role.allow_nginx_s3.name

- tags = local.common_tags
+ tags = var.common_tags
}

```

Okay, in my updated solution the bucket value is going to be var,bucket_name. In the policy statement, we're now using the variable elb_service_account_arn instead of the data source, and for the references to the bucket_name, we'll use the variable bucket_name. Scrolling down to the end of the S3 bucket resource, the tags have been updated to use the var.common tags. For the IAM role, I've updated the naming to use the bucket_name as the beginning of the name for the role, and I've updated the tags to be var.common_tags. For the role policy, I'm also using the bucket_name to name the role policy and updating the reference to the bucket_name to use the bucket_name variable. And down in the instance profile, I updated the name to use the bucket_name for naming and also updated the tags to use var.common_tags. That's everything that's in the main. 

Now the last thing to do is to create two outputs. I'll go ahead and save the main.tf file, and let's go over to outputs and I'm going to put two comments in here for the bucket object and the instance profile object. My challenge to you is to add the output values here to pass the whole bucket object and the whole instance profile object back up to the parent module. Go ahead and try that now, and when we come back we can view my updated solution. 

* Update `outputs.tf`

```ini
# Bucket object
output "web_bucket" {
  value = aws_s3_bucket.web_bucket
}

# Instance profile object
output "instance_profile" {
  value = aws_iam_instance_profile.nginx_profile
}
```


In my updated solution, we have the output web bucket, which is set to a value of aws_s3_bucket.web_bucket. Because we don't specify an attribute, it will pass the entire bucket object back as an output value. That's pretty useful. And then we do the same thing for instance profile, referring to aws_iam_instance_profile.instance_profile. We'll go ahead and save this output file, and now we need to add the module reference to our s3.tf file. I'll go ahead and select that now. Now my challenge to you is to add the module block with the proper input variables. Go ahead and pause the video now, try it out, and when we come back you can see my updated solution.
