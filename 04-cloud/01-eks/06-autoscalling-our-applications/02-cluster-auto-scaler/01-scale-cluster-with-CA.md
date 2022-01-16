# Scale a cluster with CA

## Deploy a Sample App

We will deploy an sample nginx application as a `ReplicaSet` of 1 `Pod`

Create `sample-app/nginx.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-to-scaleout
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        service: nginx
        app: nginx
    spec:
      containers:
        - image: nginx
          name: nginx-to-scaleout
          resources:
            limits:
              cpu: 500m
              memory: 512Mi
            requests:
              cpu: 500m
              memory: 512Mi

``` 

Execute

```bash
kubectl apply -f  ./06-autoscalling-our-applications/02-cluster-auto-scaler/sample-app/nginx.yaml
kubectl get deployment/nginx-to-scaleout

NAME                READY   UP-TO-DATE   AVAILABLE   AGE
nginx-to-scaleout   1/1     1            1           45s
```

## Scale our ReplicaSet

Let's scale out the replpicaset to 10

```bash
kubectl scale --replicas=10 deployment/nginx-to-scaleout

```

Some pods will be in the `Pending` state, which triggers the cluster-autoscaler to scale out the EC2 fleet.

```bash
kubectl get pods -l app=nginx -o wide --watch
```

View the cluster-autoscaler logs

```bash
kubectl -n kube-system logs -f deployment/cluster-autoscaler

```

Confirm the autoscaling by visiting `EC2 AWS Management Console` or by using

```bash
$ kubectl get nodes
NAME                                           STATUS   ROLES    AGE    VERSION
ip-192-168-2-232.eu-west-3.compute.internal    Ready    <none>   99s    v1.18.9-eks-d1db3c
ip-192-168-27-247.eu-west-3.compute.internal   Ready    <none>   107s   v1.18.9-eks-d1db3c
ip-192-168-51-216.eu-west-3.compute.internal   Ready    <none>   5h     v1.18.9-eks-d1db3c
ip-192-168-67-152.eu-west-3.compute.internal   Ready    <none>   5h     v1.18.9-eks-d1db3c
ip-192-168-72-123.eu-west-3.compute.internal   Ready    <none>   100s   v1.18.9-eks-d1db3c
```

## Cleanup Scaling

```bash
kubectl delete -f ./06-autoscalling-our-applications/02-cluster-auto-scaler/sample-app/nginx.yaml

kubectl delete -f ./06-autoscalling-our-applications/02-cluster-auto-scaler/cluster-autoscaler/autodiscover.yaml

eksctl delete iamserviceaccount \
  --name cluster-autoscaler \
  --namespace kube-system \
  --cluster lc-cluster \
  --wait

aws iam delete-policy \
  --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/k8s-asg-policy

export ASG_NAME=$(aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[? Tags[? (Key=='eks:cluster-name') && Value=='lc-cluster']].AutoScalingGroupName" --output text)

aws autoscaling \
  update-auto-scaling-group \
  --auto-scaling-group-name ${ASG_NAME} \
  --min-size 1 \
  --desired-capacity 3 \
  --max-size 4

kubectl delete hpa,svc php-apache

kubectl delete deployment php-apache

kubectl delete pod load-generator

helm -n metrics uninstall metrics-server

kubectl delete ns metrics

helm uninstall kube-ops-view

unset ASG_NAME
unset AUTOSCALER_VERSION
unset K8S_VERSION
```
