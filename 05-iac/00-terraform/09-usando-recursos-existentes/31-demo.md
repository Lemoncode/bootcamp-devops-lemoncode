# Deploying Template

I'll go ahead and pull the TERMINAL up again, and I'll switch over to the m3_commands and make sure that I'm in the correct directory, which is m3/cloud_formation_template. There we go. 

```bash
cd ./cloud-formation-template
```

And now we're going to run the command aws cloudformation deploy and pass it some arguments, starting with the template file itself, followed by the stack‑name, which we'll set to dev‑net, and then we're going to override one of the parameters giving it the environment name lc‑dev. I'll grab the entire command, copy it, and paste it down below. 

```bash
aws cloudformation deploy --template-file="vpc_template.yaml" --stack-name dev-net --parameter-overrides EnvironmentName=lc-dev
```

Now it will take a few moments for it to create this CloudFormation stack and provision all the resources inside. Once our CloudFormation stack has finished provisioning, it will have the outputs ready for viewing. 

The next command, aws cloudformation describe‑stacks, will grab the stack that we've provisioned and it will query the outputs and put them into the format of a table with the columns OutputKey and OutputValue, and then we're going to send that table to the file `table.txt`. Our stack is still provisioning, so let's jump ahead to where it has completed. All right, the stack has successfully deployed, so we'll run our second command to get those outputs into a text file. 

```
Waiting for changeset to be created..
Waiting for stack create/update to complete
Successfully created/updated stack - dev-net
```

I'll copy it and paste it down below, and that creates the table.txt file. 

```bash
aws cloudformation describe-stacks --stack-name dev-net --query 'Stacks[0].Outputs[].[OutputKey, OutputValue]' --output table > table.txt
```

Let's take a look at that file. 

```
------------------------------------------------------------------------------------------
|                                     DescribeStacks                                     |
+-------------------------------------+--------------------------------------------------+
|  PublicRouteTable                   |  rtb-03fefe77de6534e02                           |
|  PublicSubnet2RouteTableAssociation |  subnet-0c863e001a5dab480/rtb-03fefe77de6534e02  |
|  InternetGateway                    |  igw-0da8b57f4b3c96118                           |
|  DefaultPublicRoute                 |  rtb-03fefe77de6534e02_0.0.0.0/0                 |
|  VPC                                |  vpc-01eb783b1cb3557df                           |
|  PublicSubnet2                      |  subnet-0c863e001a5dab480                        |
|  NoIngressSecurityGroup             |  sg-03c2b27461e662d9f                            |
|  PublicSubnet1                      |  subnet-044fdaa80b3ebc5e4                        |
|  PublicSubnet1RouteTableAssociation |  subnet-044fdaa80b3ebc5e4/rtb-03fefe77de6534e02  |
+-------------------------------------+--------------------------------------------------+

```

We've got each output name and the value for that output. We're going to use these values in our Terraform configuration to import the resources into Terraform. But first, we need to know how import works.