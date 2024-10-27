# VPC Module

Here is the main page of the [Terraform Registry](https://registry.terraform.io/). We've already gone into the Providers section, so now let's go into the Modules section. If we look to the left, we can filter by Provider for the modules that we want. 

The module we actually want is the vpc module, which happens to be the top module here. So let's go ahead and click on that module. Within this module, I want to point out a few things. It has a basic set of instructions on how to use the module. It also provides the source code for the module on GitHub. So if you want to view what's actually in the module, you can click through on that link and view it yourself. Scrolling down a little bit, we have a README section, which describes how to potentially use this module. And then it also gives us a list of inputs that are accepted by the module, output values that are given by the module, any dependencies and the resources that would be created by the module. A lot of this is dependent on the inputs you give the module. 

We're going to be setting up a fairly basic VPC, so we can simply copy this example and paste it into our configuration and then make some simple updates. Let's do that now. 

```ini
# copy from terraform.io
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

```

* Update `network.tf`

```ini
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}


##################################################################################
# DATA
##################################################################################

```

And, we are going to be replacing a bunch of resources with this. We're going to be replacing the vpc, the internet_gateway, the subnets, the route_table, and the route_table_associations, all with this module. That's a lot of resources that we no longer have to manage. 

Let's scroll back up to the top and paste in the module example. Since this module is from the Terraform Registry, we should definitely add a version argument to pin it to a specific version. This way, if the module is updated in a way that breaks our configuration, we can test it in a development environment before upgrading to the newest version of the module. 

```diff
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
+ version = "=5.5.1"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

```

If we go back to the browser, we can see the current version is 5.4.0. So let's go ahead and pin it to 5.4.0 for now. We'll set the version = to 5.5.1, and this way it will only use that version until we change this argument. 

Okay, now we need to update some of the values that are used for the arguments here. We'll first delete the name argument since we'll be submitting that through our tags. 

```diff
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "=5.5.1"

- name = "my-vpc"
  cidr = "10.0.0.0/16"
```


Next, we'll update the cidr block to use our variable.

```diff
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "=5.4.0"

- cidr = "10.0.0.0/16"
+ cidr = var.vpc_cidr_block
```

For the availability zones argument, we want to give it a list of availability zone names that's equal to the number of subnets that we're currently using. To do that, we can use the slice function to slice off a list of names from the availability zones data source. Let's see how we do that. 

```diff
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "=5.5.1"

  cidr = var.aws_vpc_cidr_block

- azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
+ azs             = slice(data.aws_availability_zones.available.names, 0, (var.vpc_subnet_count))
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

```

The `slice` function takes a list as input and then slices off a portion of that list for use. We'll specify the data source aws_availability_zones.names. 

The next argument is the starting index for the slice. We'll start at the first element in the names list. The last argument is the ending index of our slice, and it is not inclusive, so it won't include that element in our list. We'll set that to var.vpc_subnet_count. So when our subnet count is 2, it will return 2 availability zone names and it will already be in a list format. 

Okay, for the private_subnets, we don't have any private subnets, so we can go ahead and delete the private_subnets. 

```diff
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "=5.5.1"

  cidr = var.aws_vpc_cidr_block

  azs = slice(data.aws_availability_zones.available.names, 0, (var.vpc_subnet_count))
- private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
```

For the public_subnets, we are going to need to calculate a list of public subnet CIDR ranges for our public subnets. Let's look at how we've done this already. If we scroll down to our subnets, we compute the CIDR block using the cidrsubnet function and the count.index since we're creating our subnets and accounts. We're no longer generating our subnets in account, so we need an alternate way to generate this list of CIDR subnets. 

The way that we'll do that is with a for expression. I briefly mentioned for expressions in the previous module, now it's time to dig into those a little more deeply.
