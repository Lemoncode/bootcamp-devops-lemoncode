# Implementing Configuration Management

## Overview

Terraform excels at deploying infrastructure. But when its job is done, you might want a configuration management application to take over and prepare the resource for code deployment.

Working in tandem, Terraform and a config manager, like Chef, Ansible, or Salt, can get the resource configured precisely as it should be and control configuration drift over time. In this module, you will learn how to add a configuration manager, Ansible in this case, to your Terraform configuration.

We will start our module by reviewing the current Terraform code from the application team and how we could improve it in terms of security and maintenance. Then we will look at the different configuration management tools available and why you might choose one over the other. We'll pick Ansible out of the bunch and implement it in our application code to move away from using provisioners. Lastly, we'll remove the soon‑to‑be deprecated `null_resource` and replace it with `terraform_data`.

- Reviewing the application code
- Configuration management overview
- Replace provisioners with Ansible
- Replace `null_resource` with `terraform_data`

## Terraform Limitations

Terraform is a great tool for provisioning infrastructure. It's declarative, it's idempotent, and it's easy to use. But it's not necessarily a configuration management tool. The main reason is that Terraform relies on the ability to query the current state of your infrastructure using an API and then compare the results to what's in your code.

> TODO: Add picture

### Get Test Set Loop

You can think of this as the get, test, set loop. Terraform gets what's in the current state of the environment, tests it against what's in your code, and then sets the environment to match what's in your code. Rinse and repeat.

> TODO: Add picture

This interaction happens through a provider that leverages an existing API for a given service. For example, the AWS provider uses the AWS APIs to query the current state of your infrastructure.

But when it comes to configuring an operating system or deploying an application, a Terraform doesn't have an available API or provider to perform its get, test, and set functions. That's where a configuration management tool comes in.

## Configuration Management Concepts

There's a lot of different configuration‑management tools out there, but they all have some common elements among them.

The first is identification. How does a configuration management piece of software identify which components will be managed? Usually, that's defined somewhere in an inventory file. I've got this list of servers, and they're all supposed to be web servers, and this is the configuration I should apply to them.

The next major thing is control. In order to properly apply a configuration to a resource, the config‑management software has to be able to control that resource, so the determination needs to be made how that resource is going to be managed.

The third component is accounting. I know I want a particular configuration applied to a resource. But first, I need to know the current state of that resource before I make any changes. The accounting portion of the config‑management software is what's responsible for figuring out the current state of an object and then comparing it to the desired state.

The last thing is verification. Once changes have been made, the config‑management software needs to validate that the changes it made are in line with the desired configuration that's stored wherever the configuration might be.

- Identification
  - What to manage
- Control
  - How to manage
- Accounting
  - How to report
- Verification
  - How to validate

There's a bunch of tools out there that do configuration management, and all of them should share these components in common.

Now that you have a high‑level understanding of what config‑management software should do, let's look at some of the options to consider when you're deploying your configuration‑management software.

## Deployment Options

The first thing to consider is how Terraform passes off the baton to the configuration‑management software. It has done its job and created the infrastructure, and now it needs to say, hey, config‑management software, you go ahead and do your thing. You could have Terraform directly invoke the config‑management software using a startup script or a provisioner, or your config‑management tool could be triggered by your CI/CD pipeline, or it could have some dynamic‑discovery component.

The next deployment question is, do you push the configuration, or do you pull the configuration? When I say push the configuration, that means there's some sort of centralized server that has the desired configuration and an inventory of nodes to apply that configuration to, and it goes out and pushes that to each node. `Ansible` is a good example of that deployment methodology. A pull configuration is a little bit different. In a pull configuration, you have a centralized repository that has the configurations in it, but each individual node is responsible for pulling that configuration down and applying it locally. Often, that's done through some sort of agent. For instance, Puppet has an agent that you install on each node, and then you set that agent to run on specific intervals to pull the current configuration.

The last thing to think about is sort of related to the push versus pull, and that's whether to go with a centralized or distributed configuration. A centralized model would mean that there's a centralized inventory and config‑management server that holds all the information. And often, that works in tandem with some sort of push config. Though, it could work with either. Alternatively, you could have a decentralized or distributed config‑management deployment. In that case, the configuration could be stored in some sort of shared repository, but it's a distributed repository, and there's no centralized server forcing configuration to happen on a certain cadence. In the case of distributed configuration, that scale is much larger because you don't have to rely on the bottleneck of a centralized server, but you do give up the centralized logging that comes with such a server.

- Terraform hand-off
- Push or pull
- Centralized or distributed

### Traditional Deployment

Now that we have a good idea of what configuration‑management software does and how it does it, let's talk about some deployment options, one of the ways that Terraform and config management can work in tandem to deploy a config to a target environment.

In traditional provisioning, you would typically create an image or use an existing image, and you can think of that image as either an AMI in AWS or a template in VMware. It's the base image that you use when you want to deploy a new instance.

That instance is just going to be a basic configuration, probably just the operating system patched up to a certain level. On top of that instance, you're going to provision the application, and you're either going to do that through Terraform, you could use provisioners that exist in there, or you could hand off that deployment of the application to a configuration‑management piece of software.

```
=========================================================================================>

CREATE IMAGE ===> DEPLOY INSTANCE ===> PROVISION APPLICATION ===> CONFIGURATION MANAGEMENT
```

That would do the initial provisioning of the application and then continue to manage the configuration of that app going forward. That is a fairly traditional pipeline.

### Immutable Deployment

I did want to bring up an alternative version of the provisioning pipeline that may or may not include a config manager and that's called immutable deployment. Immutable implies that once something is deployed, it isn't changed. It's not mutable.

The pipeline for immutable deployments starts out very similar. You create an image, and you deploy an instance from that image. The main difference is that image already has the operating system patched, the pre reqs for the application, and the application itself installed. All it needs is a little bit of configuration information to know where it fits into your infrastructure. But basically, that instance is ready to go from the moment it fires up. It's very similar to a container‑type deployment.

When it comes time to patch or update that application, you don't patch or update the instance. Instead, you update the image. That image is the immutable source of truth for how the deployment should be.

```
==================================================>

CREATE IMAGE ===> DEPLOY INSTANCE ===> UPDATE IMAGE
```

In a virtual‑machine context, you can use a tool like Packer to dynamically build updated versions of the image, and then that image is going to be deployed out as part of an update.

```
=====================================================================>

CREATE IMAGE ===> DEPLOY INSTANCE ===> UPDATE IMAGE ===> DEPLOY UPDATE
```

Typically, you would do a rolling upgrade where you take an instance out of service, destroy it, and create a new version of the instance from the updated image, and then continue that deployment process.

So those are two different deployment patterns. The immutable deployment is becoming more common because of containers and the way that they are deployed and applying those same principles to virtual machines. We're going to stick with the traditional pattern for now and use Ansible to manage the configuration of our application.

## Ansible Overview and Usage

In case you're not familiar with it, Ansible is an open‑source tool that is used for configuration management, application deployment, and infrastructure orchestration.

It's agentless, which means you don't have to install anything on the target system. And when running remotely, it uses `SSH` or a similar connection protocol to connect to the target remotely and configure it.

Ansible uses playbooks written in YAML to define the configuration of the system. Playbooks are made up of tasks, and they're executed in order. Tasks are made up of modules that are executed on the target system. You can think of modules as the building blocks of Ansible, and they're what actually performs the actions to configure the system.

The target systems are defined in an inventory file, which is also written in YAML. The inventory file can be a single file, or it could be a directory of files. The inventory file can also be dynamic, which means it can be generated by a script or an API call.

Ansible configuration can be centralized using the Red Hat Ansible Automation Platform or the free and open‑source alternative Ansible Semaphore.

- Open-source configuration management tool
- Agentless operation
- Connects remotely or runs locally
- Playbooks in YAML
  - Tasks and modules
- Inventory file in YAML
- Centralized control
  - Red Hat Ansible Automation
  - Ansible Semaphore

If you're interested in learning more about Ansible, there's a getting started course on Pluralsight that you can check out.


## Updating the Application Code

[Demo: Updating the Application Code](./01-updating-application-code/readme.md)

## Null Resource and Terraform Data

### null_resource

The `null_resource` is a weird resource in the sense that it doesn't actually create a resource. It exists mostly to allow you to run provisioners outside the lifecycle of a specific resource. 

The most common use is to perform a task that doesn't have a provider, like running a script to update a configuration or bootstrap a cluster. The `null_resource` takes a triggers argument that takes a map of values that will trigger the resource to be recreated, which will, in turn, run any provisioners associated with it. 

The `null_resource` is the only resource that is part of the null provider, which means that you need to install a provider plugin to use it, and HashiCorp has to maintain that provider. Although HashiCorp hasn't officially deprecated the provider, the writing is on the wall. The null_resource is going away. 

```ini
# datasources.tf

resource "null_resource" "example" {
  triggers = {
    # Watch list of instance IDs
    instance_ids = join(",", aws_instance.main.*.id)
  }

  provisioner "remote-exec" {...}
}
```

### terraform_data

So in Terraform 1.4, HashiCorp introduced the `terraform_data` resource, which is part of the built‑in Terraform provider. Meaning that it doesn't use an external plugin. Aside from the `terraform_remote_state` data source, I believe the terraform_data resource is the only other built‑in resource in that provider. Just like the `null_resource`, the `terraform_data` resource doesn't create external resources. Its creation or replacement is triggered by other resources in the configuration by specifying the triggers‑replace arguments and then a list of values to trigger on. 

When one of those trigger values changes, Terraform will recreate the `terraform_data` resource, which will kick off any provisions that are defined inside of the block. The `terraform_data` resource can also store arbitrary information in Terraform state through an input argument, and that could be used in tandem with the `replace_triggered_by` argument in another resource to trigger its recreation based on that value. 

```ini
resource "terraform_data" "example" {
  triggers_replace = [
    # Watch list of instance IDs
    instance_ids = join(",", aws_instance.main.*.id)
  ]

  provisioner "remote-exec" {...}

  # Force an update of an IAM policy
  input = var.iam_version_update
}

resource "aws_iam_policy" "example" {
  lifecycle {
    replace_triggered_by = [terraform_data.example]
  }
}
```

There's not a ton of use cases for this. But if you run into a situation where you need to force the recreation of a resource based on an arbitrary value, this is one way to do it. 

We're going to replace the existing `null_resource` with the `terraform_data` resource in the application configuration

## Removing the Null Resource

[Demo: Removing the Null Resource](./02-removing-null-resource/readme.md)

## Module Summary

In this module, we started by deciding when it makes sense to use a configuration management tool over Terraform. Turns out that Terraform is not always the best tool for the job, and that's OK. We selected Ansible as our configuration‑management tool and updated the application code to use it instead of the provisioners. There was also the null_resource to contend with, which we switched over to the newer terraform_data resource and confirmed that our existing provisioner was still working properly. But honestly, we don't really want that provision there either if we can help it. In the next module, we are going to leverage AWS Systems Manager Parameter Store as a replacement for the provisioner, and we're going to get that pesky API key out of our input variables.
