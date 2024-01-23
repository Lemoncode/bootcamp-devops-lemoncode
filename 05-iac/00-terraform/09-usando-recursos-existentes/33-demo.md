# Adding the Import Blocks

Within the configuration, I already have the import blocks defined in the `imports.tf` file. Personally, I think it's easier to track our imports by giving them their own file, and we can remove them after the import is complete. 

The first import block is for the VPC itself. 

```ini
import {
  to = module.main.aws_vpc.this[0]
  id = "VPC" #VPC
}
```

The to argument is set to `module.main.aws_vpc.this[0]`. Now, how did I know that's the value it should be? Well, I actually just ran a `terraform plan` without the import blocks to see what resources the module would create, and the address for each resource was listed in the output. 

```bash
# move out temporally imports.tf
terraform init

terraform plan

# when done remove .terraform and .terraform.lock.hcl
```

```
# module.main.aws_vpc.this[0] will be created
  + resource "aws_vpc" "this" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.42.0.0/16"
      + default_network_acl_id               = (known after apply)
      + default_route_table_id               = (known after apply)
      + default_security_group_id            = (known after apply)
      + dhcp_options_id                      = (known after apply)
      + enable_dns_hostnames                 = true
      + enable_dns_support                   = true
      + enable_network_address_usage_metrics = (known after apply)
      + id                                   = (known after apply)
      + instance_tenancy                     = "default"
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      + main_route_table_id                  = (known after apply)
      + owner_id                             = (known after apply)
      + tags                                 = {
          + "Name" = "globo-dev"
        }
      + tags_all                             = {
          + "Name" = "globo-dev"
        }
    }
```

That's a handy trick to know if you plan on using modules during your import. Now based on the documentation for the AWS VPC resource, I know the identifier should be the VPC ID, and that is handily already in the table we created earlier. So I'll open that file and grab it now. 

------------------------------------------------------------------------------------------
|                                     DescribeStacks                                     |
+-------------------------------------+--------------------------------------------------+
|  PublicRouteTable                   |  rtb-03fefe77de6534e02                           |
|  PublicSubnet2RouteTableAssociation |  subnet-0c863e001a5dab480/rtb-03fefe77de6534e02  |
|  InternetGateway                    |  igw-0da8b57f4b3c96118                           |
|  DefaultPublicRoute                 |  rtb-03fefe77de6534e02_0.0.0.0/0                 |
|  VPC                                |  vpc-01eb783b1cb3557df                           |
|  PublicSubnet2                      |  subnet-0c863e001a5dab480                        |
|  NoIngressSecurityGroup             |  sg-03c2b27461e662d9f                            |
|  PublicSubnet1                      |  subnet-044fdaa80b3ebc5e4                        |
|  PublicSubnet1RouteTableAssociation |  subnet-044fdaa80b3ebc5e4/rtb-03fefe77de6534e02  |
+-------------------------------------+--------------------------------------------------+


I'll copy the VPC ID and paste it into the identifier argument. If you'd like to challenge yourself, you can try and create the rest of the import blocks for the module instead of using the ones I've provided. I'll note that we will not be using the VPC module for our security groups, so you can skip that one. I'll pause the video now while you give it a try. Okay, we're back, and I'm going to show you the import blocks I've created. 

```diff
##################################################################################
# IMPORTS
##################################################################################

import {
  to = module.main.aws_vpc.this[0]
- id = "VPC" #VPC
+ id = "vpc-01eb783b1cb3557df" #VPC
}

import {
  to = module.main.aws_subnet.public[0]
- id = "PublicSubnet1" #PublicSubnet1
+ id = "subnet-044fdaa80b3ebc5e4" #PublicSubnet1
}

import {
  to = module.main.aws_subnet.public[1]
- id = "PublicSubnet2" #PublicSubnet2
+ id = "subnet-0c863e001a5dab480" #PublicSubnet2
}

import {
  to = module.main.aws_internet_gateway.this[0]
- id = "InternetGateway" #InternetGateway
+ id = "igw-0da8b57f4b3c96118" #InternetGateway
}

import {
  to = module.main.aws_route.public_internet_gateway[0]
- id = "DefaultPublicRoute" #DefaultPublicRoute
+ id = "rtb-03fefe77de6534e02_0.0.0.0/0" #DefaultPublicRoute
}

import {
  to = module.main.aws_route_table.public[0]
- id = "PublicRouteTable" #PublicRouteTable
+ id = "rtb-03fefe77de6534e02" #PublicRouteTable
}

import {
  to = module.main.aws_route_table_association.public[0]
- id = "PublicSubnet1/PublicRouteTable" #PublicSubnet1/PublicRouteTable
+ id = "subnet-044fdaa80b3ebc5e4/rtb-03fefe77de6534e02" #PublicSubnet1/PublicRouteTable
}

import {
  to = module.main.aws_route_table_association.public[1]
- id = "PublicSubnet2/PublicRouteTable" #PublicSubnet2/PublicRouteTable
+ id = "subnet-0c863e001a5dab480/rtb-03fefe77de6534e02" #PublicSubnet2/PublicRouteTable
}

import {
  to = aws_security_group.ingress
- id = "NoIngressSecurityGroup" #NoIngressSecurityGroup
+ id = "sg-03c2b27461e662d9f" #NoIngressSecurityGroup
}
```

I've added import blocks for the subnets, the `internet_gateway`, the route_tables, and the `route_table_associations`. Now the `route_table_associations` are a little bit strange, as they are a combination of the subnet ID and the `route_table` ID. And the default route is the `route_table` ID and the route destination. 

So, always consult the docs when importing resources because the identifier it's not always intuitive. I've also added an import block for the `security_group`, which is not part of the VPC module, so the to address is a resource block in the root module that doesn't exist yet. We'll see how Terraform handles that in a moment.
