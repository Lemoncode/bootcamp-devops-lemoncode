# Exercises

## After using `inputs/outputs` our application is not working...

1. Debug current application to find out what is going on. 
    - What are the options that we can use to debug?
    - After applying the debugging method, how can you fix the issue?
2. After, fixing the issue check that every thing is working as you exopected

After using `inputs/outputs` the application is not working in order to debug it, we add access to SSH 22 adding a new security group:

```diff
resource "aws_security_group" "nginx-sg" {
  name   = "nginx_sg"
  vpc_id = aws_vpc.vpc.id

  # HTTP access from anywhere
  ingress {
    from_port   = var.sg_ingress_port
    to_port     = var.sg_ingress_port
    protocol    = "tcp"
    cidr_blocks = var.sg_ingress_cidr_blocks
  }
+
+ ingress {
+   from_port   = 22
+   to_port     = 22
+   protocol    = "tcp"
+   cidr_blocks = ["0.0.0.0/0"]
+ }
+
  # outbound internet access
  egress {
    from_port   = var.sg_egress_port
    to_port     = var.sg_egress_port
    protocol    = "-1"
    cidr_blocks = var.sg_egress_cidr_blocks
  }

  tags = local.common_tags
}
```

We connect via AWS console, using `EC2 Instance Connect` -> `Connect using a Publi IP`. Once we are inside the EC2, we can check the service status:

```bash
systemctl status nginx
```

```bash
sudo cat /var/log/cloud-init-output.log
```

> NOTE: `dnf` is not defined
