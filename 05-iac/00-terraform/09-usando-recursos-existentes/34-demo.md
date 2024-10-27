# Running the Import Process

Now that we've got our import blocks ready, we can run terraform plan. I'll pull up the terminal. And first, let's get into the correct directory, which is the `network_config` directory. And, of course, we have to run terraform init to initialize our configuration and to download the AWS provider, as well as the VPC module from the public registry. 

```bash
cd network_config
```

```bash
terraform init
```

Now that that's complete, we'll run a terraform plan without any other arguments, 

```bash
terraform plan
```

and I'll get back in error that the security group resource block that I specified in the import block doesn't exist. 

```
Plan: 8 to import, 3 to add, 0 to change, 0 to destroy.
╷
│ Error: Import block target does not exist
│ 
│   on imports.tf line 53:
│   53: import {
│ 
│ The target for the given import block does not exist. If you wish to automatically generate config for this resource, use the -generate-config-out option within terraform plan. Otherwise, make sure the target resource
│ exists within your configuration. For example:
│ 
│   terraform plan -generate-config-out=generated.tf
```

So now, instead, let's run a terraform plan with the generate‑config‑out flag and set it equal to generated.tf. 

```bash
terraform plan -generate-config-out=generated.tf
```

This will generate the resource blocks for the security group and output them to the generated.tf file. Once the plan is complete, it should say no infrastructure changes are needed. 

> We're expecting 0 to change 

```
Plan: 9 to import, 3 to add, 0 to change, 0 to destroy.
```

But before we run and apply, let's inspect the `generated.tf` file. First, I'll hide the TERMINAL to give us a little more room and scroll down to the network_config. There is our generated.tf file. 

```ini
# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "sg-03c2b27461e662d9f"
resource "aws_security_group" "ingress" {
  description = "Security group with no ingress rule"
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  ingress                = []
  name                   = "no-ingress-sg"
  name_prefix            = null
  revoke_rules_on_delete = null
  tags                   = {}
  tags_all               = {}
  vpc_id                 = "vpc-01eb783b1cb3557df"
}

```


Inside the file, we have our resource block for the security group, and there's a nice comment noting that Terraform created this block automatically. All of the entries in the block are hard coded, including the vpc_id reference. That's not what we want. Let's update this to reference the actual VPC ID. The reference should be module.main, and the name of the output for the VPC ID is vpc_id. I'll also update the tags argument to use our local.common tags value.

Update `generated.tf`

```diff
resource "aws_security_group" "ingress" {
  description = "Security group with no ingress rule"
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  ingress                = []
  name                   = "no-ingress-sg"
  name_prefix            = null
  revoke_rules_on_delete = null
- tags                   = {}
+ tags                   = local.common_tags
  tags_all               = {}
- vpc_id                 = "vpc-01eb783b1cb3557df"
+ vpc_id = module.main.vpc_id
}
```

And let's move this resource block over to our `resources.tf` file, then we can delete the generated.tf file. 

Update `resources.tf`

```ini
##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  region = var.region
}

##################################################################################
# DATA
##################################################################################

data "aws_availability_zones" "available" {}

##################################################################################
# RESOURCES
##################################################################################
locals {
  common_tags = {

  }
}

module "main" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = var.prefix
  cidr = var.cidr_block

  azs                     = slice(data.aws_availability_zones.available.names, 0, length(var.public_subnets))
  public_subnets          = [for k, v in var.public_subnets : v]
  public_subnet_names     = [for k, v in var.public_subnets : "${var.prefix}-${k}"]
  enable_dns_hostnames    = true
  public_subnet_suffix    = ""
  public_route_table_tags = { Name = "${var.prefix}-public" }
  map_public_ip_on_launch = true

  enable_nat_gateway = false

  tags = local.common_tags
}

# diff #
resource "aws_security_group" "ingress" {
  description = "Security group with no ingress rule"
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  ingress                = []
  name                   = "no-ingress-sg"
  name_prefix            = null
  revoke_rules_on_delete = null
  tags                   = local.common_tags
  tags_all               = {}
  vpc_id                 = module.main.vpc_id
}
# diff #
```

```bash
rm generated.tf
```

Cool. Now we can run a terraform plan again and see what happens. This time, we'll skip the generate‑config‑out flag since we have our security group block, and the result is a few new resources, but no changes. 

```bash
terraform plan
```

If we scroll up past the imports to the created section, it looks like the module is taking ownership over the default route table, the `default_security_group`, and the default network ACL. Those are all special resources created with any VPC. And that's fine. The important thing is that it's not changing any of the existing resources. 

All of those resources are flagged to be imported to our state data, and we can see the change before it's applied to state. Scrolling back down to the bottom, now we can run a terraform apply. 

```bash
terraform apply
```

And after a few moments, our resources are imported, and the changes are complete. And since it doesn't have to create anything, this should go very quickly. I'll enter yes to confirm the changes. And there we go. Our apply is complete.

```
Apply complete! Resources: 9 imported, 3 added, 0 changed, 0 destroyed.
```

To confirm that we are managing the resources, let's add a tag to the local value common tags. First, I'll hide the TERMINAL, and we're going to create a new input variable for the environment value. I'll go into `variables.tf`, and scroll up to the top. And just below the variable prefix, I'm going to add a new input variable called `environment`. I'll set the type to string. We'll add a description here, setting it as Optional, and the environment we're deploying in. And for the default, I'll set it to development. 

Update `variables.tf`

```ini
# ....
variable "prefix" {
  type        = string
  description = "(Optional) Prefix to use for all resources in this module. Default: globo-dev"
  default     = "globo-dev"
}
# diff #
variable "environment" {
  type        = string
  description = "(Optional) Environment for all resources"
  default     = "development"
}
# diff #
variable "cidr_block" {
  type        = string
  description = "(Optional) The CIDR block for the VPC. Default:10.42.0.0/16"
  default     = "10.42.0.0/16"
}
# ....
```

Update `resources.tf`

With that input variable in place, we can go over to resources, scroll up to our local value common_tags, and add a value into this map of Environment = var.environment. 

```diff
locals {
  common_tags = {
+   Environment = var.environment
  }
}
```

Bringing the TERMINAL back up, I'll run a terraform plan. 

```bash
terraform plan
```

And once that completes, we'll see that, yep, we are, in fact, adding tags to our newly‑managed resources. 

```
Plan: 0 to add, 9 to change, 0 to destroy.
```

Fantastic. Let's kick off an apply to apply these changes. 

```bash
terraform apply -auto-approve
```

And once those changes are complete, we have accomplished our goal. 

```
Apply complete! Resources: 0 added, 9 changed, 0 destroyed.
```

We have successfully imported existing resources into Terraform using the import block, and we even got to use the VPC module as the destination for most of the resources. Good job. 

The last thing we need to do is delete our import.tf file since we no longer need it. 

```bash
rm imports.tf
```

You can either delete the file or comment out the import blocks in case you need them again for a different environment. I'm simply going to delete it.
