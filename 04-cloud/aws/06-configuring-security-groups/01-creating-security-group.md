# Creating Security Group

You can find security group configuration under the EC2 service. To get there, select Services, types EC2, then go to the EC2 console. On the left-hand side under Network and Security, you'll see security groups. 

[01](./.resources/01.png)

This will show you the list of your security groups. When you're creating a rule, it will either be `inbound` or `outbound`. Here are some inbound rules that were already created for this security group, and there are also a couple of outbound rules. 

[02](./.resources/02.png)

[03](./.resources/03.png)

To edit a rule, select the `Edit button`. 

Let's add a rule to check out type, protocol, and port range. There are several common configurations listed under the Type menu, such as `SSH`, `HTTP`, and `RDP`. 

When you select a type, the protocol and port range are automatically populated for you. This is helpful if you don't have all of the port numbers for different protocols memorized. I

f you need to create a custom rule, for example if you have an application running on port 8080 over TCP, you could select Custom TCP Rule, then put port 8080.