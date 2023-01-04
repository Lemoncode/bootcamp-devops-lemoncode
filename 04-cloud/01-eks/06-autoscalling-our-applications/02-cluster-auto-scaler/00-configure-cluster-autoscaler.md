# Configure Cluster Autoscaler (CA)

Cluster Autoscaler for AWS provides integration with Auto Scaling groups. It enables users to choose from four different options of deployment:

* One Auto Scaling group
* Multiple Auto Scaling groups
* Auto-Discovery
* Control-plane Node setup

Auto-Discovery is the preferred method to configure Cluster Autoscaler. Click [here](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler/cloudprovider/aws) for more information.

Cluster Autoscaler will attempt to determine the CPU, memory, and GPU resources provided by an Auto Scaling Group based on the instance type specified in its Launch Configuration or Launch Template.

## Configure the ASG

You configure the size of your Auto Scaling group by setting the minimum, maximum, and desired capacity. When we created the cluster we set these settings to 3.

```bash
aws autoscaling \
    describe-auto-scaling-groups \
    --query "AutoScalingGroups[? Tags[? (Key=='eks:cluster-name') && Value=='lc-cluster']].[AutoScalingGroupName, MinSize, MaxSize,DesiredCapacity]" \
    --output table
```

We get  the following output:

```
-------------------------------------------------------------
|                 DescribeAutoScalingGroups                 |
+-------------------------------------------+----+----+-----+
|  eks-74bb42a6-005b-046b-94fb-a10d3351576e |  1 |  4 |  3  |
+-------------------------------------------+----+----+-----+
```

Now we increase the maximum capacity to 5 instances

```bash
# we need the ASG name
export ASG_NAME=$(aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[? Tags[? (Key=='eks:cluster-name') && Value=='lc-cluster']].AutoScalingGroupName" --output text)
```

```bash
# increase max capacity up to 5
aws autoscaling \
    update-auto-scaling-group \
    --auto-scaling-group-name ${ASG_NAME} \
    --min-size 1 \
    --desired-capacity 3 \
    --max-size 5
```

```bash
# Check new values
aws autoscaling \
    describe-auto-scaling-groups \
    --query "AutoScalingGroups[? Tags[? (Key=='eks:cluster-name') && Value=='lc-cluster']].[AutoScalingGroupName, MinSize, MaxSize,DesiredCapacity]" \
    --output table
```

We must see the updated values similar to this:

```
-------------------------------------------------------------
|                 DescribeAutoScalingGroups                 |
+-------------------------------------------+----+----+-----+
|  eks-74bb42a6-005b-046b-94fb-a10d3351576e |  1 |  5 |  3  |
+-------------------------------------------+----+----+-----+
```

## IAM roles for service accounts

With IAM roles for service accounts on Amazon EKS clusters, you can associate an IAM role with a [Kubernetes service account](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/). This service account can then provide AWS permissions to the containers in any pod that uses that service account. With this feature, you no longer need to provide extended permissions to the node IAM role so that pods on that node can call AWS APIs.

Enabling IAM roles for service accounts on your cluster

```bash
eksctl utils associate-iam-oidc-provider \
    --cluster lc-cluster \
    --approve

```

Creating an IAM policy for your service account that will allow your CA pod to interact with the autoscaling groups.

file://~/Documents/lemoncode/bootcamp-devops-lemoncode/04-cloud/01-eks/06-autoscalling-our-applications/02-cluster-auto-scaler/cluster-autoscaler/k8s-asg-policy.json

```bash
aws iam create-policy   \
  --policy-name k8s-asg-policy \
  --policy-document file://~/Documents/lemoncode/bootcamp-devops-lemoncode/04-cloud/01-eks/06-autoscalling-our-applications/02-cluster-auto-scaler/cluster-autoscaler/k8s-asg-policy.json
```

```bash
# output
{
    "Policy": {
        "PolicyName": "k8s-asg-policy",
        "PolicyId": "ANPARK7SEOFUOZH6YZREC",
        "Arn": "arn:aws:iam::xxxxxxxxxxxx:policy/k8s-asg-policy",
        "Path": "/",
        "DefaultVersionId": "v1",
        "AttachmentCount": 0,
        "PermissionsBoundaryUsageCount": 0,
        "IsAttachable": true,
        "CreateDate": "2020-12-21T17:07:41+00:00",
        "UpdateDate": "2020-12-21T17:07:41+00:00"
    }
}
```

Finally, create an IAM role for the cluster-autoscaler Service Account in the kube-system namespace.

> Note: Grab the account id from the previous output

```bash
eksctl create iamserviceaccount \
    --name cluster-autoscaler \
    --namespace kube-system \
    --cluster lc-cluster \
    --attach-policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/k8s-asg-policy" \
    --approve \
    --override-existing-serviceaccounts
```

```bash
# output
[ℹ]  eksctl version 0.32.0
[ℹ]  using region eu-west-3
[ℹ]  1 existing iamserviceaccount(s) (kube-system/aws-node) will be excluded
[ℹ]  1 iamserviceaccount (kube-system/cluster-autoscaler) was included (based on the include/exclude rules)
[ℹ]  1 iamserviceaccount (kube-system/aws-node) was excluded (based on the include/exclude rules)
[!]  metadata of serviceaccounts that exist in Kubernetes will be updated, as --override-existing-serviceaccounts was set
[ℹ]  1 task: { 2 sequential sub-tasks: { create IAM role for serviceaccount "kube-system/cluster-autoscaler", create serviceaccount "kube-system/cluster-autoscaler" } }
[ℹ]  building iamserviceaccount stack "eksctl-lc-cluster-addon-iamserviceaccount-kube-system-cluster-autoscaler"
[ℹ]  deploying stack "eksctl-lc-cluster-addon-iamserviceaccount-kube-system-cluster-autoscaler"
[ℹ]  created serviceaccount "kube-system/cluster-autoscaler"
```

## Deploy the Cluster Autoscaler (CA)

Deploy the Cluster Autoscaler to your cluster with the following command.

```bash
kubectl apply -f ./06-autoscalling-our-applications/02-cluster-auto-scaler/cluster-autoscaler/autodiscover.yaml

```

To prevent CA from removing nodes where its own pod is running, we will add the `cluster-autoscaler.kubernetes.io/safe-to-evict` annotation to its deployment with the following command

```bash
kubectl -n kube-system \
    annotate deployment.apps/cluster-autoscaler \
    cluster-autoscaler.kubernetes.io/safe-to-evict="false"

```

Finally let's update the autoscaler image

```bash
# we need to retrieve the latest docker image available for our EKS version
export K8S_VERSION=$(kubectl version --short | grep 'Server Version:' | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' | cut -d. -f1,2)
export AUTOSCALER_VERSION=$(curl -s "https://api.github.com/repos/kubernetes/autoscaler/releases" | grep '"tag_name":' | sed -s 's/.*-\([0-9][0-9\.]*\).*/\1/' | grep -m1 ${K8S_VERSION})

kubectl -n kube-system \
    set image deployment.apps/cluster-autoscaler \
    cluster-autoscaler=us.gcr.io/k8s-artifacts-prod/autoscaling/cluster-autoscaler:v${AUTOSCALER_VERSION}

```

Watch the logs

```bash
kubectl -n kube-system logs -f deployment/cluster-autoscaler

```

**We are now ready to scale our cluster**