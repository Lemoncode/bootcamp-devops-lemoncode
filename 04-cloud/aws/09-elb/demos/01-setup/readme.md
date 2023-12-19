# Lab Set Up

### VPC and Subnets

- VPC: webapp-vpc
  - CIDR: 172.31.0.0/16
  - Enable DNS hostnames
  - Internet gateway: webapp-igw
- Subnets:
  - web-3a: 172.31.1.0/24
  - web-3b: 172.31.2.0/24
  - app-3a: 172.31.101.0/24
  - app-3b: 172.31.102.0/24

### Routes

- Route table: webapp-rt
  - Associate with all subnets
- Default routes:
  - IPv4: 0.0.0.0/0
  - IPv6: ::0/0
  - Target: webapp-igw

### Security Group: web-sg

| Direction | Protocol | Ports | Source        |
| :-------: | :------: | :---: | ------------- |
|  Inbound  |   TCP    |  80   | Any           |
|  Inbound  |   TCP    |  443  | Any           |
|  Inbound  |   TCP    |  81   | 172.31.0.0/16 |
|  Inbound  |   TCP    |  22   | Your IP       |

### Secuirty Group: app-sg

| Direction | Protocol |   Ports   | Source        |
| :-------: | :------: | :-------: | ------------- |
|  Inbound  |   TCP    | 8080,8443 | 172.31.1.0/24 |
|  Inbound  |   TCP    | 8080,8443 | 172.31.2.0/24 |
|  Inbound  |   TCP    |    22     | Your IP       |

### Security Group: db-sg

| Direction | Protocol | Ports | Source          |
| :-------: | :------: | :---: | --------------- |
|  Inbound  |   TCP    | 5432  | 172.31.101.0/24 |
|  Inbound  |   TCP    | 5432  | 172.31.102.0/24 |
|  Inbound  |   TCP    |  22   | Your IP         |

### Instances

| Name | Subnet |  IP address   | Security group |
| ---- | :----: | :-----------: | -------------- |
| web1 | web-3a |  172.31.1.21  | web-sg         |
| web2 | web-3b |  172.31.2.22  | web-sg         |
| web3 | web-3b |  172.31.2.23  | web-sg         |
| app1 | app-3a | 172.31.101.21 | app-sg         |
| app2 | app-3b | 172.31.102.22 | app-sg         |
| app3 | app-3b | 172.31.102.23 | app-sg         |
| db   | app-3a | 172.31.101.99 | db-sg          |

## Create Lab

Ensure you have installed AWS CLI and user configuration has privileges to create the related resources.

### Create webapp-vpc

```bash
VPC_ID=$(aws ec2 create-vpc --cidr-block 172.31.0.0/16  \
 --instance-tenancy default \
 --tag-specifications ResourceType=vpc,Tags='[{Key=Name,Value=web-vpc}]' \
  | jq -r '.Vpc."VpcId"')
```

> Enable DNS hostnames from console

### Create web tier subnets

```bash
WEB_3A=$(aws ec2 create-subnet --vpc-id $VPC_ID \
    --cidr-block 172.31.1.0/24 \
    --availability-zone eu-west-3a \
    --tag-specifications ResourceType=subnet,Tags='[{Key=Name,Value=web-3a}]' \
    | jq -r '.Subnet."SubnetId"')
```

```bash
WEB_3B=$(aws ec2 create-subnet --vpc-id $VPC_ID \
    --cidr-block 172.31.2.0/24 \
    --availability-zone eu-west-3b \
    --tag-specifications ResourceType=subnet,Tags='[{Key=Name,Value=web-3b}]' \
    | jq -r '.Subnet."SubnetId"')
```

### Create app tier subnets

```bash
APP_3A=$(aws ec2 create-subnet --vpc-id $VPC_ID \
    --availability-zone eu-west-3a \
    --cidr-block 172.31.101.0/24 \
    --tag-specifications ResourceType=subnet,Tags='[{Key=Name,Value=app-3a}]' \
    | jq -r '.Subnet."SubnetId"')
```

```bash
APP_3B=$(aws ec2 create-subnet --vpc-id $VPC_ID \
    --availability-zone eu-west-3b \
    --cidr-block 172.31.102.0/24 \
    --tag-specifications ResourceType=subnet,Tags='[{Key=Name,Value=app-3b}]' \
    | jq -r '.Subnet."SubnetId"')
```

### Create internet gateway

```bash
IGW=$(aws ec2 create-internet-gateway \
    --tag-specifications ResourceType=internet-gateway,Tags='[{Key=Name,Value=webapp-igw}]' \
    | jq -r '.InternetGateway."InternetGatewayId"')
```

```bash
aws ec2 attach-internet-gateway --internet-gateway-id $IGW  --vpc-id $VPC_ID
```

### Create route table and associate with subnets

```bash
RT=$(aws ec2 create-route-table --vpc-id $VPC_ID \
    --tag-specifications ResourceType=route-table,Tags='[{Key=Name,Value=webapp-rt}]' \
    | jq -r '.RouteTable."RouteTableId"')
```

```bash
aws ec2 associate-route-table --route-table-id $RT --subnet-id $WEB_3A
aws ec2 associate-route-table --route-table-id $RT --subnet-id $WEB_3B
aws ec2 associate-route-table --route-table-id $RT --subnet-id $APP_3A
aws ec2 associate-route-table --route-table-id $RT --subnet-id $APP_3B
```

### Add default routes

```bash
aws ec2 create-route \
 --route-table-id $RT \
 --destination-cidr-block 0.0.0.0/0 \
 --gateway-id $IGW
```

### Create Security Groups

```bash
WEBSG=$(aws ec2 create-security-group \
--group-name web-sg \
--description "web-sg" \
--vpc-id $VPC_ID | jq -r '.GroupId')

APPSG=$(aws ec2 create-security-group \
--group-name app-sg \
--description "app-sg" \
--vpc-id $VPC_ID | jq -r '.GroupId')

DBSG=$(aws ec2 create-security-group \
--group-name db-sg \
--description "db-sg" \
--vpc-id $VPC_ID | jq -r '.GroupId')
```

### Set up permissions on Security Groups

```bash
aws ec2 authorize-security-group-ingress \
--group-id $WEBSG \
--ip-permissions '[{"IpProtocol":"tcp","FromPort":80,"ToPort":80,"IpRanges":[{"CidrIp":"0.0.0.0/0"}]},{"IpProtocol":"tcp","FromPort":443,"ToPort":443,"IpRanges": [{"CidrIp":"0.0.0.0/0"}]},{"IpProtocol":"tcp","FromPort":8443,"ToPort":8443,"IpRanges":[{"CidrIp":"172.31.1.0/24"},{"CidrIp":"172.31.2.0/24"},{"CidrIp":"172.31.101.0/24"},{"CidrIp":"172.31.102.0/24"}]},{"IpProtocol": "tcp","FromPort":81,"ToPort":81,"IpRanges":[{"CidrIp":"172.31.0.0/16"}]},{"IpProtocol":"tcp","FromPort":22,"ToPort": 22,"IpRanges":[{"CidrIp": "0.0.0.0/0"}]}]'
```

```bash
aws ec2 authorize-security-group-ingress \
--group-id $APPSG \
--ip-permissions '[{"IpProtocol":"tcp","FromPort":8080,"ToPort":8080,"IpRanges":[{"CidrIp":"172.31.1.0/24"},{"CidrIp":"172.31.2.0/24"},{"CidrIp":"172.31.101.0/24"},{"CidrIp":"172.31.102.0/24"}]},{"IpProtocol":"tcp","FromPort":8443,"ToPort":8443,"IpRanges":[{"CidrIp":"172.31.1.0/24"},{"CidrIp":"172.31.2.0/24"},{"CidrIp":"172.31.101.0/24"},{"CidrIp":"172.31.102.0/24"}]},{"IpProtocol":"tcp","FromPort":22,"ToPort":22,"IpRanges":[{"CidrIp":"0.0.0.0/0"}]}]'
```

```bash
aws ec2 authorize-security-group-ingress \
--group-id $DBSG \
--ip-permissions '[{"IpProtocol":"tcp","FromPort":27017,"ToPort":27017,"IpRanges":[{"CidrIp":"172.31.101.0/24"},{"CidrIp":"172.31.102.0/24"}]},{"IpProtocol":"tcp","FromPort":22,"ToPort":22,"IpRanges": [{"CidrIp": "0.0.0.0/0"}]}]'
```

### Set instance defaults

```bash
INSTANCE_TYPE=t3.micro
IMAGE_ID=ami-0302f42a44bf53a45
```

### Create web instances

```bash
aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type $INSTANCE_TYPE \
    --subnet-id $WEB_3A \
    --key-name devops_trainer_key \
    --security-group-ids $WEBSG \
    --associate-public-ip-address \
    --private-ip-address 172.31.1.21 \
    --tag-specifications ResourceType=instance,Tags='[{Key=name,Value=web1}]'
```

```bash
aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type $INSTANCE_TYPE \
    --subnet-id $WEB_3B \
    --key-name devops_trainer_key \
    --security-group-ids $WEBSG \
    --associate-public-ip-address \
    --private-ip-address 172.31.2.22 \
    --tag-specifications ResourceType=instance,Tags='[{Key=name,Value=web2}]'
```

```bash
aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type $INSTANCE_TYPE \
    --subnet-id $WEB_3B \
    --key-name devops_trainer_key \
    --security-group-ids $WEBSG \
    --associate-public-ip-address \
    --private-ip-address 172.31.2.23 \
    --tag-specifications ResourceType=instance,Tags='[{Key=Name,Value=web3}]'
```

### Create app instances

```bash
aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type $INSTANCE_TYPE \
    --subnet-id $APP_3A \
    --key-name devops_trainer_key \
    --security-group-ids $APPSG \
    --associate-public-ip-address \
    --private-ip-address 172.31.101.21 \
    --tag-specifications ResourceType=instance,Tags='[{Key=Name,Value=app1}]'
```

```bash
aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type $INSTANCE_TYPE \
    --subnet-id $APP_3B \
    --key-name devops_trainer_key \
    --security-group-ids $APPSG \
    --associate-public-ip-address \
    --private-ip-address 172.31.102.22 \
    --tag-specifications ResourceType=instance,Tags='[{Key=Name,Value=app2}]'
```

```bash
aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type $INSTANCE_TYPE \
    --subnet-id $APP_3B \
    --key-name devops_trainer_key \
    --security-group-ids $APPSG \
    --associate-public-ip-address \
    --private-ip-address 172.31.102.23 \
    --tag-specifications ResourceType=instance,Tags='[{Key=Name,Value=app3}]'
```

### Create db instance

```bash
aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type $INSTANCE_TYPE \
    --subnet-id $APP_3A \
    --key-name devops_trainer_key \
    --security-group-ids $DBSG \
    --associate-public-ip-address \
    --private-ip-address 172.31.101.99 \
    --tag-specifications ResourceType=instance,Tags='[{Key=Name,Value=db}]'
```