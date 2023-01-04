# Build your first EKS Cluster

## Introduction

The official CLI to launch a cluster is `eksctl`, this is a tool develop by weavworks on conjuntion of AWS team. The goal of this tool is to build an `EKS cluster` much easier. If we thing the things that we have to do to build a cluster, we have to create VPC, provision subnets (multiples of them), set up routing in your VPC, then you can go to the control plane on the console and launch the cluster. All the infrastructure could be done using `CloudFormation`, but still being a lot of work.

We can build the cluster from `EKS Cluster console`, all the choices expose there can be done with `eksctl`

## How do I check the IAM role on the workspace?

```bash
aws sts get-caller-identity
```

## Create EC2 Key

```bash
aws ec2 create-key-pair --key-name EksKeyPair --query 'KeyMaterial' --output text > EksKeyPair.pem
```

Modify permissions over the private key to avoid future warnings

```bash
chmod 400 EksKeyPair.pem
``` 

With this new private key we can go ahead and generate a public one, that's the key that will be upload into the node (EC2 instance). If we provide this key, and we have the private one, we can connect to the remote instance.

```bash
ssh-keygen -y -f EksKeyPair.pem > eks_key.pub
```

## Create definition YAML

```yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: lc-cluster
  region: eu-west-3
  version: "1.21"

iam:
  withOIDC: true

managedNodeGroups:
  - name: lc-nodes
    instanceType: t2.small
    desiredCapacity: 3
    minSize: 1
    maxSize: 4
    ssh:
      allow: true
      publicKeyPath: "./eks_key.pub"
``` 

```bash
eksctl create cluster \
--name lc-cluster \
--version 1.21 \
--region eu-west-3 \
--nodegroup-name lc-nodes \
--node-type t2.small \
--nodes 3 \
--nodes-min 1 \
--nodes-max 4 \
--with-oidc \
--ssh-access=true \
--ssh-public-key=eks_key.pub \
--managed
```

Both forms are going to create exactly the same, but if we want to get all the power of `eksctl` we have to use the declarative way using the yaml form.

## Understanding eks file

`eksctl` is going to build our cluster using this file.

```yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: lc-cluster # [1]
  region: eu-west-3 # [2]
  version: "1.18" # [3]

iam:
  withOIDC: true # [4]

managedNodeGroups: # [5]
  - name: lc-nodes # [6]
    instanceType: t2.small # [7]
    desiredCapacity: 3 # [8]
    minSize: 1 # [9]
    maxSize: 4 # [10]
    ssh: # [11]
      allow: true # will use ~/.ssh/id_rsa.pub as the default ssh key
      publicKeyPath: "./eks_key.pub" # Add path to key
``` 

1. This is the cluster name, in our case `lc-cluster`
2. The AZ where the cluster is going to be deplyed
3. The Kuberntes version that we're going to use, if we let it empty, will use the last stable for `AWS`
4. enables the IAM OIDC provider as well as IRSA for the Amazon CNI plugin
5. [`managedNodeGroups`](https://eksctl.io/usage/eks-managed-nodes/) are a way for the `eks service` to actually provision your data plane on your behalf so normally if you think about the of a container orchestrator it's jsut orchestarte containers on your compute so we're starting to see expansion of that role a little bit so now instead of you bringing your own compute and you having to manage patching it, updating it, rolling in new versions of it and all that day to day stuff, it's possible to be managed by AWS, this is what `managedNodeGroup` does. AWS provides the AMI and provisioning into your account on your behalf.
6. The name of the group of nodes
7. The instance type that we're running. We're usding the free tier
8. The number of nodes that we want to have on the node group
9. If the cluster infrastructure is updated the minimun mumber of instances that we want on the node group
10. If the cluster infrastructure is updated the max number of instances that we want on the node group
11. The `ssh` key to connect to our EC2 instances.


## Launching the Cluster

Before launchin the cluster we can use the `dry-run` feature, this will allow us to inspect and change the instances matched by the instance selector before proceeding to creating a nodegroup. If we run `eksctl create cluster <options> --dry-run`, `eksctl` will output a ClusterConfig file containing a nodegroup representing the CLI options and the instance types set to the instances matched by the instance selector resource criteria.

```bash
eksctl create cluster -f demos.yml --dry-run
```

Now we're ready to launch the cluster

```bash
eksctl create cluster -f demos.yml
``` 

## Test the cluster

Now we can test that our cluster is up and running.

```bash
kubectl get nodes
```

> `eksctl` has edit `./kube/config` to make `kubectl` point to the new created cluster.