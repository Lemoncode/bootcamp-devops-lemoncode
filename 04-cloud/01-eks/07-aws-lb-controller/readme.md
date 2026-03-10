# AWS Load Balancer controller

## Deploy solution

```bash
helm create lc-sample
```

```bash
cd lc-sample
```

```bash
helm install lc-sample-chart .
```

```bash
kubectl get pods
```

```bash
kubectl get deployments
```

## Install AWS Load Balancer Controller

```bash
# INSTALL AWS Load Balancer Controller
CLUSTER_NAME=bootcamp-lemon-review
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
SERVICE_ACCOUNT_NAME="aws-load-balancer-controller"
```

```bash
# Deploys the CloudFormation stack that has the IAM policy for the Controller
aws cloudformation deploy \
    --stack-name aws-load-balancer-iam-policy \
    --template-file aws-lbc-iam-policy.yaml \
    --capabilities CAPABILITY_IAM

aws_load_balancer_iam_policy=$(aws cloudformation describe-stacks --stack aws-load-balancer-iam-policy --query "Stacks[0].Outputs[0]" | jq .OutputValue | tr -d '"')
```

> NOTE: `--capabilities CAPABILITY_IAM` - explicitly acknowledges that this template will create IAM resources

```bash
# Creates the IAM Roles for Service Account for the Controller
eksctl create iamserviceaccount \
    --cluster=${CLUSTER_NAME} \
    --namespace=kube-system \
    --name=${SERVICE_ACCOUNT_NAME} \
    --attach-policy-arn=${aws_load_balancer_iam_policy} \
    --override-existing-serviceaccounts \
    --approve
```

```bash
# Deploys the Controller with the Service Account created in the previous step
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=${CLUSTER_NAME} \
    --set serviceAccount.create=false \
    --set serviceAccount.name=${SERVICE_ACCOUNT_NAME}
```

Verify installation

```bash
kubectl get pods -n kube-system
```

## Expose the Application

Update `lc-sample/values.yaml`

```diff
service:
  # This sets the service type more information can be found here: https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types
- type: ClusterIP
+ type: NodePort
  # This sets the ports more information can be found here: https://kubernetes.io/docs/concepts/services-networking/service/#field-spec-ports
  port: 80
```

Other changes is here in the ingress section. The first one is to enable it because the controller uses to do everything what it does. 

```diff
# This block is for setting up the ingress for more information can be found here: https://kubernetes.io/docs/concepts/services-networking/ingress/
ingress:
- enabled: false
+ enabled: true
  className: ""
  annotations: {}
```

Let's add some annotations. The first one will be the ingres.class one, basically to make it an application load balancer, or ALB, and the second one is to make it internet facing so that we can access it through the internet without any type of private access. 


```diff
ingress:
  enabled: true
  className: ""
- annotations: {}
-   # kubernetes.io/ingress.class: nginx
-   # kubernetes.io/tls-acme: "true"
+ annotations:
+   kubernetes.io/ingress.class: alb
+   alb.ingress.kubernetes.io/scheme: internet-facing
```

We are not going to use a custom DNS. So instead of this, we're going to put an empty string like this. 

```diff
ingress:
  enabled: true
  className: ""
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
  hosts:
-   - host: chart-example.local
+   - host: ""
```

Basically, what we are doing is making sure that the host is going to be a wildcard. And finally, in the path type, we want to put prefix. 

```diff
ingress:
  enabled: true
  className: ""
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
  hosts:
    - host: ""
      paths:
        - path: /
-         pathType: ImplementationSpecific
+         pathType: Prefix
```

Get the name of the Helm chart we were working with before `helm ls` or `list`:

```bash
helm ls
```

```bash
cd lc-sample
helm upgrade lc-sample-chart .
```

```bash
kubectl get ingress
```

There you go. Here's our ingress, and as you can see, it already has an address, and this address is the DNS of the load balancer that should be already been provisioned in AWS. 

It is not going to work right now if it is still provisioning, so let's go to EC2 and see the status of the creation over there. 

> Open AWS Console

Okay, in the left panel, let's scroll down until we find load balancers, and there you go. Here's our load balancer being provisioned right now. So I'm going to pause the video here, and we'll come back after this is done. It normally takes between 3 and 5 minutes. 

Okay, we're back, and as you can see, the status of our load balancer is active. So let's see some details here. If we scroll down to the listeners, we can see there's only one which unique rule is going to be pointing to the target group that has the EC2 instances that expose our nginx application. Let's go back to a load balancer, and let's give it a try. 

Let's use this DNS name in another tab to see if the application loads up, and there you go. As you can see, we have a Welcome to nginx message, meaning that we are accessing our nginx pod through an application load balancer.