# EC2 Access

## Default Security Group

- Named "default"
- Created for each VPC
- Allows:
    - Inbound from same SG

## EC2 Login Troubleshooting

[Demo: Login Troubleshooting](./demos/01-login-troubleshooting.md)

### Ensuring Access to EC2

- Create an inbound rule to allow proper access to machine
    - SSH
    - RDP
- Source from your IP address
    - DANGER from any IP
- If still no access, verify no restrictions in Network ACL
    - NACL associated with subnet

## Access to Apps on EC2

[Demo: Accessing Apps]()