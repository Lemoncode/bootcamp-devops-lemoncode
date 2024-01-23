Update `management/variables.tf`

```ini
# ....
variable "instance_type" {
  type        = string
  description = "(Optional) EC2 Instance type to use for web app. Defaults to t3.micro."
  default     = "t3.micro"
}

# diff #
variable "playbook_repository" {
  type        = string
  description = "URI of Ansible playbook"
  default     = "https://github.com/JaimeSalas/ansible-playbook-nginx.git"
}
# diff #
```


Update `management/templates/userdata.sh`

> Replace the contents with this new version

```bash
#!/bin/bash
sudo yum update
sudo yum install git -y
sudo amazon-linux-extras install ansible2 -y
sudo mkdir /var/ansible_playbooks
sudo git clone ${playbook_repository} /var/ansible_playbooks
ansible-playbook /var/ansible_playbooks/playbook.yml -i /var/ansible_playbooks/hosts
```


Update `management/resources.tf`

```diff
# ...
resource "aws_instance" "main" {
  ami           = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type = var.instance_type
  subnet_id     = module.main.public_subnets[0]
  vpc_security_group_ids = [
    aws_security_group.webapp_http_inbound_sg.id,
    aws_security_group.webapp_ssh_inbound_sg.id,
    aws_security_group.webapp_outbound_sg.id,
  ]

  key_name = module.ssh_keys.key_pair_name
+
+ user_data_replace_on_change = true
+
+ user_data = templatefile("./templates/userdata.sh", {
+   playbook_repository = var.playbook_repository
+ })

- # Provisioner Stuff
-   connection {
-     type        = "ssh"
-     user        = "ec2-user"
-     port        = "22"
-     host        = self.public_ip
-     private_key = module.ssh_keys.private_key_openssh
-   }
-
-   provisioner "file" {
-     source      = "./templates/userdata.sh"
-     destination = "/home/ec2-user/userdata.sh"
-   }
-
-   provisioner "remote-exec" {
-     inline = [
-       "chmod +x /home/ec2-user/userdata.sh",
-       "sh /home/ec2-user/userdata.sh",
-     ]
-     on_failure = continue
-   }
-
}

```

```bash
terraform fmt
```

```bash
terraform validate
```

```bash
AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY
AWS_SECRET_ACCESS_KEY=YOUR_SECRET_ACCESS_KEY
```

```bash
terraform plan -out m2.tfplan
```

 