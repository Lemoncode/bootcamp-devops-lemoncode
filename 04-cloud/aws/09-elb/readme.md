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

## Provision the Web Tier

[Demo: Web Tier Deploy](./demos/03-web-tier-deploy/readme.md)

## Creating and HTTP Target Group

### Supported Protocols

- HTTP
- HTTPS
- TCP

### Port Range

- TCP/1-65535
- AWS will change the port number to match the protocol
- HTTP or TCP: 80
- HTTPS: 443

### Target Types

| Instance                                                         | IP                                                     |
| ---------------------------------------------------------------- | ------------------------------------------------------ |
| Routes traffic to the primary private IP address of the instance | Routes traffic to a specified IP address               |
|                                                                  | RFC 1918: 10.0.0.0/8, 172.16.0.0/12 and 192.168.0.0/16 |
|                                                                  | RFC 6598: 100.64.0.0/10                                |

### Health Checks

- Determines wether to send traffic to a given instance
- Each instance must pass its health check before receiving traffic
- Sends HTTP GET request and looks for a success code

[Demo: Creating HTTP Target Groups](./demos/04-create-target-groups/readme.md)

## Create the Application Load Balancer

[Demo: Creating Application Load Balancer](./demos/05-create-app-lb/readme.md)

## Testing the Load Balancer

[Demo: Testing the Load Balancer](./demos/06-testing-lb/readme.md)

## Registering Additional Targets

We're going to deploy the web front end on `web2` and `web3` and add those instances as targets to our target group.

[Demo: Registering Additional Targets](./demos/07-additional-targets/readme.md)

## Creating an Internal Load Balancer

[Demo: Creating an Internal Load Balancer](./demos/08-internal-lb/readme.md)

## Using Internal Load Balancer

[Demo: Using Internal Load Balancer](./demos/09-using-internal-lb/readme.md)

## Provisioning Database Tier

[Demo: Provisioning Database Tier](./demos/10-provisioning-db/readme.md)

## Sticky Sessions and Idle Timeouts

> Sticky Sessions: Ensure a unique client's request always gets forwarded to the same target

### Idle Timeouts

- Client and load balancer establish a TCP connection
- HTTP(S) requests and response traverse this connection
- Control how long the TCP connection with a client can remain idle before closing it

### Stickiness Duration

- How long load balancer will maintain sticky session between clinet and target
- Load balancer sets a browser cookie with a unique, encrypted value
- Client sends back the cookie with each subsequent request
- Between 1 second and 7 days

[Demo: Sticky Sessions](./demos/11-sticky-session/readme.md)

[Demo: Idle Timeout]()