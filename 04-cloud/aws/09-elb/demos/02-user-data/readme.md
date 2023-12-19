# User Data

Lets start by creating a script that will install Docker on the instance type that we're using:

Create `install-docker.txt`

```bash
#!/bin/bash
sudo dnf update
sudo dnf install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
newgrp docker
```

If we want to start a new instance with user data we can do as follows:

```bash
aws ec2 run-instances --image-id <image id> --count 1 --instance-type <instance type> \
--key-name my-key-pair --subnet-id <subnet id> --security-group-ids <sg-id> \
--user-data file://my_script.txt
```

We're going to use the Ireland region and the default vpc and subnet. So lets try to grab the values that we need to do this:

```bash
VPC=$(aws ec2 describe-vpcs --region eu-west-1 | jq -r '.Vpcs[0]."VpcId"')
```

Lets also create a security that allows SSH Traffic

```bash
SSHSG=$(aws ec2 create-security-group \
--group-name ssh-sg \
--description "ssh-sg" \
--region eu-west-1 \
--vpc-id $VPC | jq -r '.GroupId')
```

```bash
aws ec2 authorize-security-group-ingress \
  --group-id $SSHSG \
  --region eu-west-1 \
  --ip-permissions '[{"IpProtocol":"tcp","FromPort": 22,"ToPort": 22,"IpRanges": [{"CidrIp":"0.0.0.0/0"}]}]'
```

For last we need a subnet on default VPC, lets grab one:

```bash
SUBNET=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC" \
--region eu-west-1 | jq -r '.Subnets[0]."SubnetId"')
```

We need to create a key in order to access our new instance, go to dashboard and create `dublin_key`

With this we're finally ready to try to start our instance with user data:

> NOTE: We have taken the image id from region AMI Catalog

```bash
aws ec2 run-instances --image-id ami-07355fe79b493752d \
 --count 1 --instance-type t3.micro \
 --key-name dublin_key --subnet-id $SUBNET --security-group-ids $SSHSG \
 --region eu-west-1 \
--user-data file://install-docker.txt
```

Now lets conenct to instance:

```bash
ssh -i "dublin_key.pem" ec2-user@ec2-54-78-159-28.eu-west-1.compute.amazonaws.com
```

If we just simply run `docker` we will see the list of available commands. But if we try any command with out sudo, we will get an error. 

```bash
docker ps
```

We can check that docker is running, by checking the service status:

```bash
sudo systemctl status docker
```

The reason for that, is that the $USER during installation, is not the same one that we are using when we're connected via SSH, lets fix that:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

Now if we run `docker ps` everything looks good.

## References

- https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html#user-data-shell-scripts