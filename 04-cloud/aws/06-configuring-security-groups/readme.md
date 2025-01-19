# Configuring Security Groups

## Introduction

A **security group is a virtual firewall for your EC2 instance**. It will control both the `inbound` and the `outbound` traffic **to and from your instance**.

- Security groups belong to a VPC
- Assigned at instance level
- Can use same SG in different subnets in same VPC
- Same subnet can have different security groups

> Page 1

### Traffic flow to instance

1. Internet or VPN Gateway 
2. Router 
3. Route table 
4. Network access control list (NACL) 
5. Security Group

> Page 2

### Security Group vs. NACL

|                             Security group                             |                        Network Access Control List                         |
| :--------------------------------------------------------------------: | :------------------------------------------------------------------------: |
|                             Instance level                             |                                Subnet level                                |
|                            Allow rules only                            |                            Allow and deny rules                            |
|               Evaluate all rules before allowing traffic               |                      Rules processed in numeric order                      |
| Stateful: return traffic automatically allowed regardless of any rules |       Stateless: return traffic must be explicitly allowed by rules        |
|       Applies to instance only if associate with security group        | Automatically applies to all instances in subnets associated with the NACL |

### Security Groups Are Dynamic

- Assign multiple security groups to an instance
- Change the security group(s) assigned to an instance
- Modify secuirty group rules
- Changes to security group are applied immediately

## Security Group Rules

- Type: Pre-defined protocol / port combinations
- Protocol: TCP, UDP, ICMP
- Port Range: Which port are allowed as part of the rule

## Source and Destination

- Security Group
  - ID of another security group
- IP Address
  - IPv4 or IPv6 CIDR block
  - Single address (/32 or /128)