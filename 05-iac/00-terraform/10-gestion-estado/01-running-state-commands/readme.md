# Running State Commands

All right, here we are in Visual Studio Code, and I am going to expand m4 in our modules, and I'm going to open the m4_commands.txt file. First, we're going to try out some of our Terraform state commands. So let's open up the TERMINAL. If you're not already in the network_config folder, navigate to that to run the state commands. 

```bash
cd .lab/network_config
```

The first one we'll run is terraform state list, and I'll expand the TERMINAL to give us a little more room to view the output. 

```bash
terraform state list
```

```
data.aws_availability_zones.available
aws_security_group.ingress
module.main.aws_default_network_acl.this[0]
module.main.aws_default_route_table.default[0]
module.main.aws_default_security_group.this[0]
module.main.aws_internet_gateway.this[0]
module.main.aws_route.public_internet_gateway[0]
module.main.aws_route_table.public[0]
module.main.aws_route_table_association.public[0]
module.main.aws_route_table_association.public[1]
module.main.aws_subnet.public[0]
module.main.aws_subnet.public[1]
module.main.aws_vpc.this[0]
```

The output gives us things like the address of the `internet_gateway`, the `route_tables`, the `route_table_associations`, our various subnets, etc. That's what we would expect. 

These are the resources we have deployed. Now what if we wanted to get more information about a particular item in this list? That's when we use `terraform state show`. So I have this command here that gets more information about the VPC. I'll copy it and paste it down below and run the command, and it has now printed out all the information it has about our VPC that's stored inside state data. 

```bash
terraform state show module.main.aws_vpc.this[0]
```

```ini
# module.main.aws_vpc.this[0]:
resource "aws_vpc" "this" {
    arn                                  = "arn:aws:ec2:eu-west-3:092312727912:vpc/vpc-01eb783b1cb3557df"
    assign_generated_ipv6_cidr_block     = false
    cidr_block                           = "10.42.0.0/16"
    default_network_acl_id               = "acl-01373011200152246"
    default_route_table_id               = "rtb-016f32f58c208daa5"
    default_security_group_id            = "sg-05030426aa49a3c76"
    dhcp_options_id                      = "dopt-0b486312449742eae"
    enable_dns_hostnames                 = true
    enable_dns_support                   = true
    enable_network_address_usage_metrics = false
    id                                   = "vpc-01eb783b1cb3557df"
    instance_tenancy                     = "default"
    ipv6_netmask_length                  = 0
    main_route_table_id                  = "rtb-016f32f58c208daa5"
    owner_id                             = "092312727912"
    tags                                 = {
        "Environment" = "development"
        "Name"        = "globo-dev"
    }
    tags_all                             = {
        "Environment" = "development"
        "Name"        = "globo-dev"
    }
}
```

We can scroll up and see all the information here. If you were looking to reference one of the attributes about the VPC, here you can also get the attribute names about that resource in case you need to reference them. It's probably important to point out that since the VPC resource is in a module, the root module doesn't have direct access to the attributes of the resource. Instead, we would need to expose it through an output like we did with the VPC ID. 

The `show` command can list out the attributes stored in state, but you still need to be mindful of module scoping. We can also pull all of the state data by doing `terraform state pull`. Let's grab that command and paste it down below, and that's going be a lot of information. 

```bash
terraform state pull
```

This is the entire `JSON` file. It's not very useful for you to try to parse through on your own, and that's why we have these other commands. But it is available if you wanted to dump this out to some sort of third‑party tool. That's going do it for the state commands. Now let's dig into where you can store this state data. You've got options.