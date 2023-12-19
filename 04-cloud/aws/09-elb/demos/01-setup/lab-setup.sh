#!/bin/bash

# Create VPC
VPC_ID=$(aws ec2 create-vpc --cidr-block 172.31.0.0/16  \
 --instance-tenancy default \
 --tag-specifications ResourceType=vpc,Tags='[{Key=Name,Value=web-vpc}]' \
  | jq -r '.Vpc."VpcId"')

# WARNING: Enable DNS hostnames from console!!!

echo VPC_ID=$VPC_ID

# Create web tier subnets
WEB_3A=$(aws ec2 create-subnet --vpc-id $VPC_ID \
    --cidr-block 172.31.1.0/24 \
    --availability-zone eu-west-3a \
    --tag-specifications ResourceType=subnet,Tags='[{Key=Name,Value=web-3a}]' \
    | jq -r '.Subnet."SubnetId"')

WEB_3B=$(aws ec2 create-subnet --vpc-id $VPC_ID \
    --cidr-block 172.31.2.0/24 \
    --availability-zone eu-west-3b \
    --tag-specifications ResourceType=subnet,Tags='[{Key=Name,Value=web-3b}]' \
    | jq -r '.Subnet."SubnetId"')

echo WEB_3A=$WEB_3A 
echo WEB_3B=$WEB_3B

# Create app tier subnets
APP_3A=$(aws ec2 create-subnet --vpc-id $VPC_ID \
    --availability-zone eu-west-3a \
    --cidr-block 172.31.101.0/24 \
    --tag-specifications ResourceType=subnet,Tags='[{Key=Name,Value=app-3a}]' \
    | jq -r '.Subnet."SubnetId"')

APP_3B=$(aws ec2 create-subnet --vpc-id $VPC_ID \
    --availability-zone eu-west-3b \
    --cidr-block 172.31.102.0/24 \
    --tag-specifications ResourceType=subnet,Tags='[{Key=Name,Value=app-3b}]' \
    | jq -r '.Subnet."SubnetId"')

echo APP_3A=$APP_3A 
echo APP_3B=$APP_3B

# Create internet gateway
IGW=$(aws ec2 create-internet-gateway \
    --tag-specifications ResourceType=internet-gateway,Tags='[{Key=Name,Value=webapp-igw}]' \
    | jq -r '.InternetGateway."InternetGatewayId"')

aws ec2 attach-internet-gateway --internet-gateway-id $IGW  --vpc-id $VPC_ID

echo IGW=$IGW 

# Create route table and associate with subnets
RT=$(aws ec2 create-route-table --vpc-id $VPC_ID \
    --tag-specifications ResourceType=route-table,Tags='[{Key=Name,Value=webapp-rt}]' \
    | jq -r '.RouteTable."RouteTableId"')

echo RT=$RT

aws ec2 associate-route-table --route-table-id $RT --subnet-id $WEB_3A
aws ec2 associate-route-table --route-table-id $RT --subnet-id $WEB_3B
aws ec2 associate-route-table --route-table-id $RT --subnet-id $APP_3A
aws ec2 associate-route-table --route-table-id $RT --subnet-id $APP_3B

# Add default routes
aws ec2 create-route \
 --route-table-id $RT \
 --destination-cidr-block 0.0.0.0/0 \
 --gateway-id $IGW

# Create security groups
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

echo WEBSG=$WEBSG
echo APPSG=$APPSG
echo DBSG=$DBSG

# Set up permissions on Security Groups
aws ec2 authorize-security-group-ingress \
 --group-id $WEBSG \
 --ip-permissions '[{"IpProtocol":"tcp","FromPort":80,"ToPort":80,"IpRanges":[{"CidrIp":"0.0.0.0/0"}]},{"IpProtocol":"tcp","FromPort":443,"ToPort":443,"IpRanges": [{"CidrIp":"0.0.0.0/0"}]},{"IpProtocol":"tcp","FromPort":8443,"ToPort":8443,"IpRanges":[{"CidrIp":"172.31.1.0/24"},{"CidrIp":"172.31.2.0/24"},{"CidrIp":"172.31.101.0/24"},{"CidrIp":"172.31.102.0/24"}]},{"IpProtocol": "tcp","FromPort":81,"ToPort":81,"IpRanges":[{"CidrIp":"172.31.0.0/16"}]},{"IpProtocol":"tcp","FromPort":22,"ToPort": 22,"IpRanges":[{"CidrIp": "0.0.0.0/0"}]}]'

aws ec2 authorize-security-group-ingress \
 --group-id $APPSG \
 --ip-permissions '[{"IpProtocol":"tcp","FromPort":8080,"ToPort":8080,"IpRanges":[{"CidrIp":"172.31.1.0/24"},{"CidrIp":"172.31.2.0/24"},{"CidrIp":"172.31.101.0/24"},{"CidrIp":"172.31.102.0/24"}]},{"IpProtocol":"tcp","FromPort":8443,"ToPort":8443,"IpRanges":[{"CidrIp":"172.31.1.0/24"},{"CidrIp":"172.31.2.0/24"},{"CidrIp":"172.31.101.0/24"},{"CidrIp":"172.31.102.0/24"}]},{"IpProtocol":"tcp","FromPort":22,"ToPort":22,"IpRanges":[{"CidrIp":"0.0.0.0/0"}]}]'

aws ec2 authorize-security-group-ingress \
 --group-id $DBSG \
 --ip-permissions '[{"IpProtocol":"tcp","FromPort":27017,"ToPort":27017,"IpRanges":[{"CidrIp":"172.31.101.0/24"},{"CidrIp":"172.31.102.0/24"}]},{"IpProtocol":"tcp","FromPort":22,"ToPort":22,"IpRanges":[{"CidrIp": "0.0.0.0/0"}]}]'

# Set instance defaults
INSTANCE_TYPE=t3.micro
IMAGE_ID=ami-0302f42a44bf53a45

# Create web instances
aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type $INSTANCE_TYPE \
    --subnet-id $WEB_3A \
    --key-name devops_trainer_key \
    --security-group-ids $WEBSG \
    --associate-public-ip-address \
    --private-ip-address 172.31.1.21 \
    --tag-specifications ResourceType=instance,Tags='[{Key=Name,Value=web1}]'

aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type $INSTANCE_TYPE \
    --subnet-id $WEB_3B \
    --key-name devops_trainer_key \
    --security-group-ids $WEBSG \
    --associate-public-ip-address \
    --private-ip-address 172.31.2.22 \
    --tag-specifications ResourceType=instance,Tags='[{Key=Name,Value=web2}]'

aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type $INSTANCE_TYPE \
    --subnet-id $WEB_3B \
    --key-name devops_trainer_key \
    --security-group-ids $WEBSG \
    --associate-public-ip-address \
    --private-ip-address 172.31.2.23 \
    --tag-specifications ResourceType=instance,Tags='[{Key=Name,Value=web3}]'

# Create app instances
aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type $INSTANCE_TYPE \
    --subnet-id $APP_3A \
    --key-name devops_trainer_key \
    --security-group-ids $APPSG \
    --associate-public-ip-address \
    --private-ip-address 172.31.101.21 \
    --tag-specifications ResourceType=instance,Tags='[{Key=Name,Value=app1}]'

aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type $INSTANCE_TYPE \
    --subnet-id $APP_3B \
    --key-name devops_trainer_key \
    --security-group-ids $APPSG \
    --associate-public-ip-address \
    --private-ip-address 172.31.102.22 \
    --tag-specifications ResourceType=instance,Tags='[{Key=Name,Value=app2}]'

aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type $INSTANCE_TYPE \
    --subnet-id $APP_3B \
    --key-name devops_trainer_key \
    --security-group-ids $APPSG \
    --associate-public-ip-address \
    --private-ip-address 172.31.102.23 \
    --tag-specifications ResourceType=instance,Tags='[{Key=Name,Value=app3}]'

# Create db instance
aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type $INSTANCE_TYPE \
    --subnet-id $APP_3A \
    --key-name devops_trainer_key \
    --security-group-ids $DBSG \
    --associate-public-ip-address \
    --private-ip-address 172.31.101.99 \
    --tag-specifications ResourceType=instance,Tags='[{Key=Name,Value=db}]'