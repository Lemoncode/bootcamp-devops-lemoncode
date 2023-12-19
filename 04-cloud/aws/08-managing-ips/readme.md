# Managing IPs

## Internal and External IPs

- Internal IP
    - Can NOT be addressed directly from outside internet
    - Based on subnet CIDR block
- External IP
    - CAN be addressed directly from outside 
    - Pulled from AWS pool of external IP addresses
    - Must select on launch or have auto-assign public IP enabled

## Create and Use a Bastion Server

[Demo: Create and Use a Bastion Server](./demos/01-bastion-server.md)

## Disable Auto-assign Public IP

- We can change this behaviour from subnet settings.
- We can disable it on instance launch

## Internal vs. External IP

|                                                  Internal | External                                                                   |
|----------------------------------------------------------:|----------------------------------------------------------------------------|
|                          Addressable from inside VPC only | Addressable from outside of VPC                                            |
|                   Stays the same for lifetime of instance | Allow and deny rules                                                       |
|                                      Based on subnet CIDR | Pulled from AWS pool of external IPs                                       |
|                                 Assigned to all instances | Only assigned on launch if enabled                                         |

[Demo: Using EIP](./demos/02-eip.md)