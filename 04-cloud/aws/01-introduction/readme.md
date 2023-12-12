# Introduction

## Regions and Availability Zones

### Regions and Availability Zones

- **What is a region?**
  - Geographic Location
  - Disaster
  - Performance

- **What is and Availability Zone?**
  - Isolated set of resources within a region
  - Fire or power outage in one AZ should not affect another AZ
  - High speed network connection between AZs


#### AWS Regions

- For general use, choose region closest to you
- Not all regions have all AWS services available
- Cost of services can differ from region to region
- Legal or compliance requirements for applications and data

### Compliance and Security

- Data centers
  - https://aws.amazon.com/compliance/data-center/
- Certifications, laws, alignments
  - ISO, SOC, HIPPA, etc.
  - https://aws.amazon.com/compliance/programs/
- General info
  - https://aws.amazon.com/compliance

#### Shared Responsability

- [aws.amazon.com/compliance/shared-responsibility-model/](https://aws.amazon.com/compliance/shared-responsibility-model/)

|    Security OF cloud | Security IN cloud |
| -------------------: | ----------------- |
| Physical data center | Configuration     |
|             Hardware | Credentials       |
|             Software | Application       |
|           Networking | Customer data     |

### Instance Deployment Models

- **Single instance**
  - Most basic setup
  - Single point of failure
  - Used for
    - Development
    - Proof of concepts

- **Multiple INstances**
  - Redundant
    - Instances
    - Availability Zones
  - Live updates
  - Used for
    - Production where region failure is acceptable risk

- **Multiple Instances & Multiple Regions**
  - Most complex
  - Highest cost
  - Highest level of redundancy
  - Consider all pieces of system
    - Instances
    - Databases
    - S3 buckets

## AWS Networking Services Overview

### VPC

- Logically isolated piece of the AWS cloud
- Foundation for EC2 (compute) instances
- Subnets
- IP address range for instances
- Access control to and from instances

#### VPC Architecture 

- VPC belongs to a region
  - Spans all availability zones
- Multiple VPCs per region
- VPCs contain subnets
  - Subnets are in a single availability zone
  - EC2 instances launched into subnets

#### Default VPC

- Created with AWS account
  - Each region has a default VPC
- Subnet in each AZ
- Ready to launch instances
- Use for simple applications
- Modify default or build additional VPCs

### IP Adresses

#### Internal IP Addresses

- IPv4 address range required for VPC
  - Classless Inter-Domain Routing (CIDR) block
- Subnet CIDR Block
  - Subset of VPC CIDR
  - Subnets cannot overlap
  - Ensure enough capacity
- Instance Address

  - Determined by subnet CIDR

- CIDR Blocks - Allowed block size between /16 and /28
  - `10.0.0.0/16` - 65.536 possible addresses (10.0.0.0 - 10.0.255.255)
  - `10.0.0.0/28` - 16 possible addresses (10.0.0.0 - 10.0.0.15)
  - Subnet block - AWS reserves first 4 and last address of each subnet block

#### External IP Addresses

- Must specify if want public IP
  - Instance creation
- Assigned by AWS
  - Will change when stop and start instance
- Elastic IP
  - Stays assigned
  - Better for long term instances
  - Can be re-assigned

### Ingress and Egress

- Security groups determine allowed traffic to / from instances by port, protocol, source, and destination
- Network access control lists (NACL) specify allow / deny rules for traffic in and out of a subnet
- VPCs can be peered to allow traffic between VPCs including different regions and AWS accounts - like being on same network
- VPCs can be accessed via virtual private network (VPN) 
- Route tables to control traffic in / out of subnets
- Provide access to external internet with an internet gateway
- Use NAT gateway to provide external internet access for _private_ subnets

### VPC Design Patterns

### Elastic Load Balancing

### Route 53 (DNS)

### API Gateway

### CloudFront (CDN)

### Direct Connect

### Private Link
