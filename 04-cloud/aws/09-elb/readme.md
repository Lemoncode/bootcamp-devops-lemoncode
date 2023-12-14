# Elastic Load Balancer

## Load Balancer Types

- Classic
- Application
- Network

### Classic Load Balancer

- Designed for EC2-Classic network
- Not recommended for VPC

### Application Load Balancer

- HTTP and HTTPS
- Terminates the client connection
- TCP ports 1 - 65535
- Listener supports IPv6
- Path and host-based routing

### Network Load Balancer

- Supports any TCP connection
- Layer 4 load balancer
- Handles high traffic at low latency
- Does not terminate HTTP(S) connections

## Set Up

[Demo: Set up](./demos/01-setup/readme.md)

## Avoid intall Docker manually

Right now, we need to SSH into each machine to install Docker. We can avoid this behaviour by using `user data`.

- User data is passed to the instance at launch and is available through the instance metadata service on the instance.

- You can specify user data when launching an instance using the AWS CLI, SDKs, or console to pass configuration scripts or other data to the instance.

- The user data string is available to all instances that are part of the same reservation if multiple instances are launched together.

- You cannot change the user data of a running instance, but you can retrieve the existing user data using the describe-instance-attribute command.

[Demo: Avoid intall Docker manually](./demos/02-user-data/readme.md)