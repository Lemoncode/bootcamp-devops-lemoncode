# Configuration Management

Create `management/terraform.tf`

```ini
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}

```

Create `management/datasources.tf`

```ini
data "aws_ssm_parameter" "amzn2_linux" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

data "aws_availability_zones" "available" {}
```


Create `management/keys.tf`

```ini
# Create SSH Key pair for aws instances using a module
module "ssh_keys" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "~>2.0.0"

  key_name           = "public-management-keys"
  create_private_key = true
}

```

Create `management/variables.tf`

```ini
variable "region" {
  type        = string
  description = "(Optional) AWS Region to deploy in. Defaults to us-east-1."
  default     = "eu-west-3"
}

variable "cidr_block" {
  type        = string
  description = "(Required) The CIDR block for the VPC. Default:10.42.0.0/16"
  default     = "10.42.0.0/16"
}

variable "public_subnet" {
  type        = string
  description = "(Required) Public subnet to create with CIDR block."
  default     = "10.42.10.0/24"
}

variable "instance_type" {
  type        = string
  description = "(Optional) EC2 Instance type to use for web app. Defaults to t3.micro."
  default     = "t3.micro"
}
```

Create `management/main.tf`

```ini
module "main" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "management-vpc"
  cidr = var.cidr_block

  azs                     = slice(data.aws_availability_zones.available.names, 0, 1)
  public_subnets          = [var.public_subnet]
  enable_dns_hostnames    = true
  map_public_ip_on_launch = true

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Name = "management-vpc"
  }
}

```

Create `management/security_groups.tf`

```ini
##################################################################################
# RESOURCES
##################################################################################

resource "aws_security_group" "webapp_http_inbound_sg" {
  name        = "management-http-inbound"
  description = "Allow HTTP from Anywhere"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = module.main.vpc_id
}

resource "aws_security_group" "webapp_ssh_inbound_sg" {
  name        = "management-ssh-inbound"
  description = "Allow SSH from certain ranges"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = module.main.vpc_id
}

resource "aws_security_group" "webapp_outbound_sg" {
  name        = "management-webapp-outbound"
  description = "Allow outbound connections"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = module.main.vpc_id
}

```

Create `management/resources.tf`

```ini
##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  region = var.region
}

##################################################################################
# RESOURCES
##################################################################################

resource "aws_instance" "main" {
  ami           = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type = var.instance_type
  subnet_id     = module.main.public_subnets[0]
  vpc_security_group_ids = [
    aws_security_group.webapp_http_inbound_sg.id,
    aws_security_group.webapp_ssh_inbound_sg.id,
    aws_security_group.webapp_outbound_sg.id,
  ]

  key_name = module.ssh_keys.key_pair_name

  # Provisioner Stuff
  connection {
    type        = "ssh"
    user        = "ec2-user"
    port        = "22"
    host        = self.public_ip
    private_key = module.ssh_keys.private_key_openssh
  }

  provisioner "file" {
    source      = "./templates/userdata.sh"
    destination = "/home/ec2-user/userdata.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/userdata.sh",
      "sh /home/ec2-user/userdata.sh",
    ]
    on_failure = continue
  }

}

```

Create `management/templates/userdata.sh`

```bash
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
sudo rm /usr/share/nginx/html/index.html
echo '<html><head><title>Lemon Server</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">You did it! Have a rest!!</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
```

Create `management/outputs.tf`

```ini
output "webapp_instance_public_ip" {
  value = aws_instance.main.public_ip
}

output "private_key_pem" {
  value = nonsensitive(module.ssh_keys.private_key_pem)
}
```

```bash
terraform init
```

```bash
terraform fmt
```

```bash
terraform validate
```

```bash
AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY
AWS_SECRET_ACCESS_KEY=YOUR_SECRET_ACCESS_KEY
```

```bash
terraform plan -out m1.tfplan
```