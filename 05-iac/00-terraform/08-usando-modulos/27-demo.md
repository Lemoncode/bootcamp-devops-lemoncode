# For Expression

We are trying to create a tuple of cidrsubnet addresses to pass to the public subnets argument. The number of elements in the tuple should equal the value stored in vpc_subnet_count, which means we'll need an input to the for expression that is a list of integers from 0 to the value in vpc_subnet_count. Fortunately, there is a function called range that will do exactly that. Let me pull up the terminal, and we'll start up terraform console to test out these expressions. 

```bash
terraform console
```

First we will test the range function. The syntax is the range function and then the value you want it to count up to. We'll specify the variable vpc_subnet_count. Range will hand back a list of 0 and 1. 

```bash
> range(var.vpc_subnet_count)
tolist([
  0,
  1,
])
```

That sounds good; that's a good start. Now we have a list to use as an input value for the for expression. For the evaluation portion of the expression, we can use the cidrsubnet function, passing it the vpc_cidr_block variable, 8 bits to add to the subnet mask, and the element value in our input list. Let's try to construct a for expression with that information. 

```bash
> [ for subnet in range(var.vpc_subnet_count) : cidrsubnet(var.vpc_cidr_block, 8, subnet) ]
[
  "10.0.0.0/24",
  "10.0.1.0/24",
]
```

We'll start the expression with square brackets because we want a tuple back, we'll have the for keyword to start our for expression, we can set an iterator for our list, we'll call it subnet, and that's going to be in the range, and we'll set the range to var.vpc_subnet_count, which we know will return a list with two elements, 0 and 1. Then we'll add the colon and then the expression we want to use for the result of each element. We'll do the cidrsubnet function, we'll feed it the variable vpc_cidr_block, 8, to add 8 bits to the subnet mask, and then the subnet iterator. That will be 0 on the first evaluation and 1 on the second. We'll close that parentheses for the cidrsubnet function and close the for expression with a square bracket. I'll go ahead and hit Enter, and we get back a tuple that has two subnets in it. Perfect, that's exactly what we need. And this will be dynamic based off of the values of the cidr_block and the subnet_count. 

Let's go ahead and copy this entire expression, and I'll hide the terminal. Scrolling up to our vpc module, we can replace the value for public_subnets with our new expression. 

* Update `network.tf`

```diff
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "=5.4.0"

  cidr = var.vpc_cidr_block

  azs = slice(data.aws_availability_zones.available.names, 0, (var.vpc_subnet_count))
- public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
+ public_subnets = [for subnet in range(var.vpc_subnet_count) : cidrsubnet(var.vpc_cidr_block, 8, subnet)]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
```


Okay, there we go. For enable_nat_gateway, we want to set that to false. 

```diff
- enable_nat_gateway = true
+ enable_nat_gateway = false
```

We don't have any private subnets, so we do not need a NAT gateway. We'll also set enable_vpn_gateway to false, because we are not using a VPN gateway. 

```diff
- enable_vpn_gateway = true
+ enable_vpn_gateway = false
```

For our tags, we can go down and grab the tags argument from our existing VPC resource, and go ahead and paste that as the value for the tags argument in the module. There we go. 

```diff
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "=5.5.1"

  cidr = var.vpc_cidr_block

  azs = slice(data.aws_availability_zones.available.names, 0, (var.vpc_subnet_count))

  public_subnets = [for subnet in range(var.vpc_subnet_count) : cidrsubnet(var.vpc_cidr_block, 8, subnet)]

  enable_nat_gateway = false
  enable_vpn_gateway = false

- tags = {
-   Terraform   = "true"
-   Environment = "dev"
- }
+ tags = merge(local.common_tags, {
+   Name = "${local.name_prefix}-vpc"
+ })
}
```

Set up map_public_ip_on_launch and enable_dns_host_names

```diff
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "=5.4.0"

  cidr = var.vpc_cidr_block

  azs            = slice(data.aws_availability_zones.available.names, 0, (var.vpc_subnet_count))
  public_subnets = [for subnet in range(var.vpc_subnet_count) : cidrsubnet(var.vpc_cidr_block, 8, subnet)]
+
+ map_public_ip_on_launch = var.subnet_map_punlic_ip_on_launch
+ enable_dns_hostnames    = var.vpc_enable_dns_hostnames
+
  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}
```


With our vpc module ready to go, we can remove the other resources. 

```diff
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "=5.5.1"

  cidr = var.vpc_cidr_block

  azs = slice(data.aws_availability_zones.available.names, 0, (var.vpc_subnet_count))

  public_subnets = [for subnet in range(var.vpc_subnet_count) : cidrsubnet(var.vpc_cidr_block, 8, subnet)]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}


##################################################################################
# DATA
##################################################################################

data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

data "aws_availability_zones" "available" {
  state = "available"
}

##################################################################################
# RESOURCES
##################################################################################

# # NETWORKING #
- resource "aws_vpc" "vpc" {
-   cidr_block           = var.aws_vpc_cidr_block
-   enable_dns_hostnames = var.aws_vpc_enable_dns_hostnames
-
-   tags = merge(local.common_tags, {
-     Name = "${local.name_prefix}-vpc"
-   })
- }
-
- resource "aws_internet_gateway" "igw" {
-   vpc_id = aws_vpc.vpc.id
-
-   tags = merge(local.common_tags, {
-     Name = "${local.name_prefix}-igw"
-   })
- }
-
- resource "aws_subnet" "subnets" {
-   count = var.vpc_subnet_count
-   cidr_block              = cidrsubnet(var.aws_vpc_cidr_block, 8, count.index)
-   vpc_id                  = aws_vpc.vpc.id
-   map_public_ip_on_launch = var.aws_subnet_map_public_ip_on_launch
-   availability_zone       = data.aws_availability_zones.available.names[count.index]
-
-   tags = merge(local.common_tags, {
-     Name = "${local.name_prefix}-subnet-${count.index}"
-   })
- }
-
- # ROUTING #
- resource "aws_route_table" "rtb" {
-   vpc_id = aws_vpc.vpc.id
-
-   route {
-     cidr_block = var.aws_route_table_cidr_block
-     gateway_id = aws_internet_gateway.igw.id
-   }
-
-   tags = merge(local.common_tags, {
-     Name = "${local.name_prefix}-rtb"
-   })
- }
-
- resource "aws_route_table_association" "rta-subnets" {
-   count          = var.vpc_subnet_count
-   subnet_id      = aws_subnet.subnets[count.index].id
-   route_table_id = aws_route_table.rtb.id
- }
-
# SECURITY GROUPS #
# Nginx security group 
resource "aws_security_group" "nginx-sg" {
  # name   = "nginx_sg"
  name   = "${local.name_prefix}-nginx_sg"
  vpc_id = aws_vpc.vpc.id

  # HTTP access from anywhere
  ingress {
    from_port   = var.aws_sg_ingress_port
    to_port     = var.aws_sg_ingress_port
    protocol    = "tcp"
    cidr_blocks = [var.aws_vpc_cidr_block]
  }

  # outbound internet access
  egress {
    from_port   = var.aws_sg_egress_port
    to_port     = var.aws_sg_egress_port
    protocol    = "-1"
    cidr_blocks = var.aws_sg_egress_cidr_blocks
  }

  tags = local.common_tags
}

resource "aws_security_group" "alb_sg" {
  # name   = "nginx_alb_sg"
  name   = "${local.name_prefix}-nginx_alb_sg"
  vpc_id = aws_vpc.vpc.id

  # HTTP access from anywhere
  ingress {
    from_port   = var.aws_sg_ingress_port
    to_port     = var.aws_sg_ingress_port
    protocol    = "tcp"
    cidr_blocks = var.aws_sg_ingress_cidr_blocks
  }

  # outbound internet access
  egress {
    from_port   = var.aws_sg_egress_port
    to_port     = var.aws_sg_egress_port
    protocol    = "-1"
    cidr_blocks = var.aws_sg_egress_cidr_blocks
  }

  tags = local.common_tags
}

resource "aws_security_group" "connection-sg" {
  name   = "connection_sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = var.aws_sg_connection_port
    to_port     = var.aws_sg_connection_port
    protocol    = "tcp"
    cidr_blocks = var.aws_sg_ingress_cidr_blocks
  }
}

```

There we go, I have removed all the resources that we're replacing with the vpc module. Now the next thing we need to do is replace any of the references to our VPC resources with the module references. There are two output values that you'll need to use to update the rest of the configuration. 

The first is the **vpc_id**, and the second is the **public_subnets** list. For the vpc_id, we'll update the expression to module.vpc.vpc_id. 

```diff
resource "aws_security_group" "nginx-sg" {
  name = "${local.name_prefix}-nginx_sg"
- vpc_id = aws_vpc.vpc.id
+ vpc_id = module.vpc.vpc_id
  # HTTP access from anywhere
  ingress {
    from_port   = var.aws_sg_ingress_port
    to_port     = var.aws_sg_ingress_port
    protocol    = "tcp"
    cidr_blocks = [var.aws_vpc_cidr_block]
  }

  # outbound internet access
  egress {
    from_port   = var.aws_sg_egress_port
    to_port     = var.aws_sg_egress_port
    protocol    = "-1"
    cidr_blocks = var.aws_sg_egress_cidr_blocks
  }

  tags = local.common_tags
}

resource "aws_security_group" "alb_sg" {
  name = "${local.name_prefix}-nginx_alb_sg"
- vpc_id = aws_vpc.vpc.id
+ vpc_id = module.vpc.vpc_id

  # HTTP access from anywhere
  ingress {
    from_port   = var.aws_sg_ingress_port
    to_port     = var.aws_sg_ingress_port
    protocol    = "tcp"
    cidr_blocks = var.aws_sg_ingress_cidr_blocks
  }

  # outbound internet access
  egress {
    from_port   = var.aws_sg_egress_port
    to_port     = var.aws_sg_egress_port
    protocol    = "-1"
    cidr_blocks = var.aws_sg_egress_cidr_blocks
  }

  tags = local.common_tags
}
```

Vpc_id is the output value from our vpc module. We also need to update anywhere that the subnets are referenced. For example, let's go to the load balancer. 

* Update `loadbalancer.tf`

```diff
resource "aws_lb" "nginx" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
- subnets            = aws_subnet.subnets[*].id
+ subnets = module.vpc.public_subnets

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.web_bucket.bucket
    prefix  = "alb-logs"
    enabled = true
  }

  tags = local.common_tags
}
```

In the load balancer we were referencing all of the public subnets with this expression. We need to update the value for the argument to use the public subnets that are created by the module. To do that, we will update the value to module.vpc.public_subnets, which is a list of all the public subnets. My challenge to you is to go through the rest of the configuration and update it to use these module outputs.

* Update `loadbalancer.tf`

```diff
resource "aws_lb_target_group" "nginx" {
  name     = "${local.name_prefix}-alb-tg"
  port     = 80
  protocol = "HTTP"
- vpc_id   = aws_vpc.vpc.id
+ vpc_id = module.vpc.vpc_id

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
- subnet_id     = aws_subnet.subnets[(count.index % var.vpc_subnet_count)].id
+ subnet_id = module.vpc.public_subnets[(count.index % var.vpc_subnet_count)]
  ....
```


If you have any questions, you can always reference the solution that's in the m8_solution directory. Go ahead and pause the video now, and when we come back we are going to create our S3 module.

```bash
terraform init
terraform validate
terraform plan -out d6.tfplan
terraform apply "d6.tfplan"
```

We get the following errors, that are related with the public IPs:

```
│ Error: Error deleting security group: DependencyViolation: resource sg-03d1c7238178d500c has a dependent object
│       status code: 400, request id: 9131c604-134e-4ec4-af0c-9671841be9f7
│ 
│ 
╵
╷
│ Error: error deleting EC2 Subnet (subnet-0846e7623e328e86b): DependencyViolation: The subnet 'subnet-0846e7623e328e86b' has dependencies and cannot be deleted.
│       status code: 400, request id: 967081d6-2f8f-4db4-8db8-b4b275b2e417
│ 
│ 
╵
╷
│ Error: error detaching EC2 Internet Gateway (igw-0fa20466f4cb93e00) from VPC (vpc-065495b6de9af9fb1): DependencyViolation: Network vpc-065495b6de9af9fb1 has some mapped public address(es). Please unmap those public address(es) before detaching the gateway.
│       status code: 400, request id: 863467d3-5018-47c7-a299-48574c4a4dd7
│ 
│ 
╵
╷
│ Error: error deleting Target Group: ResourceInUse: Target group 'arn:aws:elasticloadbalancing:eu-west-3:092312727912:targetgroup/globoweb-dev-alb-tg/927fdeb6728d6a0a' is currently in use by a listener or a rule
│       status code: 400, request id: fe90b92b-2921-48a8-a9bd-90e8db6f5027
│ 
│ 
╵
╷
│ Error: error deleting EC2 Subnet (subnet-0f94ab0614d2116f6): DependencyViolation: The subnet 'subnet-0f94ab0614d2116f6' has dependencies and cannot be deleted.
│       status code: 400, request id: 77e809cd-820b-468a-b633-915d7094403c
│ 
│ 
╵
```

Use `terraform destroy` and then 

```bash
terraform plan -out d6.tfplan
terraform apply "d6.tfplan"
```