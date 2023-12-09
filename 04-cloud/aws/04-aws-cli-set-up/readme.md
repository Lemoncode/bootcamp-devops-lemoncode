# AWS CLI Set up

Now that we have created a user, and created an access key for this user, we can set up the AWS CLI to grant progrmmatic access. But first what is AWS CLIC?

## What is AWS CLI?

The `AWS CLI` is a unified tool to manage your AWS services from the command line and automate them through scripts. With just one tool to download and configure, you can control multiple AWS services.

The `AWS CLI` allows you to interact with AWS services using commands in your terminal shell. You can run commands on your local Linux/Windows environment or remotely on EC2 instances to manage AWS resources. 

Some key things the AWS CLI allows you to do:

- Explore AWS service capabilities and develop scripts to manage resources
- Implement same functionality as AWS Management Console from the command line
- Available on Linux, Windows and can be used remotely on EC2 instances
- Provides direct access to AWS service APIs for automation and development
- AWS services may provide custom commands to simplify usage of complex APIs

To use the `AWS CLI`, **you need to install it on your local system or EC2 instance which has internet access**. You can then configure it with your AWS credentials. This allows the CLI to make API calls to different AWS services.

## Setting Up

For simplicity, we're using Dev Containers to provide the AWS CLI binary. Check `.devcontainer` folder, with `Docker` and VS Code install in your system select `Reopen in container`, your system will ve running inside `Ubuntu` with `root user` by default (you can change this by configuriing dev container options).

Open a new terminal and run the following command:

```bash
aws --version
```

We must get a similar output:

```
aws-cli/2.14.1 Python/3.11.6 Linux/5.15.49-linuxkit exe/aarch64.ubuntu.22 prompt/off
```

Using `AWS CLI` we can set up different profiles, for simplicity we're going just to set up the `default` profile.

```bash
aws configure
```

1. Use the previously created `Acces Key`
2. Use the previously created `Secret Acces Key`
3. Set up the desired region (`eu-west-3` for example)
4. Output format: `json`

## Using AWS CLI

Lets check that is working, lets check the EC2 instances that are running on a given region:

```bash
aws ec2 describe-instances --region eu-west-3
```

This will return details of all the EC2 instances in the specified region. Notice that the given output format is `json`, the one that we previously selected.


## References

- [What is the AWS Command Line Interface? - AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)
- [What is the AWS Command Line Interface version 1? - AWS Command Line Interface](https://docs.aws.amazon.com/cli/v1/userguide/cli-chap-welcome.html)
- [Additional Documentation for the Amazon Simple Workflow Service - Amazon Simple Workflow Service](https://docs.aws.amazon.com/amazonswf/latest/developerguide/resources-docs.html)