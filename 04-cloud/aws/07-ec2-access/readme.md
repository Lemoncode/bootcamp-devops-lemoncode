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

[Demo: Accessing Apps](./demos/02-accessing-apps.md)

### Access to Apps on EC2 Summary

- Ensure the application is running 
    - Localhost check
- Create an inbound rule to allow proper access to application
    - Protocol / Port
- Source from desired IP address
    - OK for any IP depending on your app

## Outbound Access on EC2

- Default security group allows all outbound access from EC2
    - Access restricted if oubound rule is removed or changed
- Return response from http server or machine still works
    - Security group rules are stateful
        - Inbound rule allows port 80 so response is automatically allowed regardless of outbound rules