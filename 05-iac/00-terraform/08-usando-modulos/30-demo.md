# Validating and Applying the Updated Configuration

We have updated our configuration to use a VPC module from the Terraform Registry and an S3 module that we wrote ourselves. Let's go ahead and get those changes deployed. I'll go ahead and open up the m8_commands file. And the first thing we need to do is run Terraform in it because Terraform needs to get these modules and include them in the configuration. So I'll go ahead and open up the terminal. There we go. And we'll run Terraform in it. 

```bash
terraform init
terraform fmt -recursive
terraform validate
```

Okay, Terraform has successfully initialized. If we scroll up, we can see under initializing modules that it downloaded the VPC module and placed it in the .terraform\modules\vpc folder. Because our globo‑web‑app‑s3 module is already in the local directory, it will not try to download or copy the files for that module. 

All right, now that we have successfully initialized Terraform, the next step, of course, is to run terraform fmt. But we don't just want to format our files in the globo_web_app directory, we also want to make sure that the files in our S3 module are formatted properly. And we can do that by running terraform fmt‑recursive to go into those subdirectories and properly format those files as well. And there we go, it has updated the formatting for all of our files. 

The next step is to run terraform validate. All right, excellent. Our updated configuration is valid. 

The next step would be to export your environment variables if you haven't already done so. 

```bash
export AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=YOUR_SECRET_ACCESS_KEY
```

And after that, we'll run Terraform plan and send the output to m8.tfplan. We'll go ahead and run that now. Since we're moving a lot of things to modules, it's also going to have to recreate a lot of our infrastructure. Again, I'm glad we're doing this all in development before we roll anything out to production. Let's go ahead and run terraform apply to apply all of these changes. 

```bash
terraform plan -out m8.tfplan
terraform apply m8.tfplan
```

If you happen to be running in production and you needed to move resources from the root module to a child module, that's a case where using the terraform state mv command can help you move things from the existing address to a new address that's inside the module, and that would stop Terraform from destroying the target infrastructure that you're trying to update. That's a pretty advanced topic, which we're not going to get into here. For our purposes, we're still in the development environment, so tearing down this infrastructure and recreating it is no big deal. 

This is going to take a while, so I'll go ahead and pause the recording now, and we'll resume when the deployment has completed successfully. All right, our deployment is successful, let's go and check on our website. Copy that address, and go over to a browser. And there we go, our website is up and running and we are now using a VPC module and an S3 module. That's awesome.