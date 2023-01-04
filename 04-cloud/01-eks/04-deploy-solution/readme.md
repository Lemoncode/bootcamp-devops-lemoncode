# Deploy Solutions Example

## Creating bacckend services

### Creating lc-age-service

Create `lc-age-service/kubernetes/deployment.yaml`

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lc-age-service
  labels:
    app: lc-age-service
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: lc-age-service
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: lc-age-service
    spec:
      containers:
        - image: jaimesalas/lc-age-service:latest
          imagePullPolicy: Always
          name: lc-age-service
          ports:
            - containerPort: 3000
              protocol: TCP

```

Create `lc-age-service/kubernetes/service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: lc-age-service
spec:
  selector:
    app: lc-age-service
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000

```

### Creating lc-name-service

Create `lc-name-service/kubernetes/deployment.yaml`

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lc-name-service
  labels:
    app: lc-name-service
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: lc-name-service
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: lc-name-service
    spec:
      containers:
        - image: jaimesalas/lc-name-service:latest
          imagePullPolicy: Always
          name: lc-name-service
          ports:
            - containerPort: 3000
              protocol: TCP

``` 

Create `lc-name-service/kubernetes/service.yaml`


```yaml
apiVersion: v1
kind: Service
metadata:
  name: lc-name-service
spec:
  selector:
    app: lc-name-service
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000

``` 


## Deploy lc-age-service Backend API

Let's start by bringing up `lc-age-service` Backend API

```bash
cd lc-age-service
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
``` 

We can check the progress by looking at the deployment status:

```bash
kubectl get deployemnt lc-age-service
``` 

## Deploy lc-name-service Backend API

Let's continue by bringing up `lc-name-service`  Backend API

```bash
cd lc-name-service
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
``` 

We can check the progress by looking at the deployment status:

```bash
kubectl get deployemnt lc-name-service
``` 

### Creating lc-front

Create `lc-front/kubernetes/deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lc-front
  labels:
    app: lc-front
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: lc-front
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: lc-front
    spec:
      containers:
        - image: jaimesalas/lc-front:latest
          imagePullPolicy: Always
          name: lc-front
          ports:
            - containerPort: 3000
              protocol: TCP
          env:
            - name: AGE_SERVICE_URL
              value: "http://lc-age-service.default.svc.cluster.local/"
            - name: NAME_SERVICE_URL
              value: "http://lc-name-service.default.svc.cluster.local/"

``` 

Create `lc-front/kubernetes/service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: lc-front
spec:
  selector:
    app: lc-front
  type: LoadBalancer
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000

```

Before we bring up the frontend service, let's take a look at the service types we are using:

> Notice `type: LoadBalancer`: This will configure an ELB to handle incoming traffic to this service.

If we compare to this other service, for one of our backend services:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: lc-age-service
spec:
  selector:
    app: lc-age-service
  ports:
   -  protocol: TCP
      port: 80
      targetPort: 3000
```

Notice there is no specific service type described. The default type is `ClusterIP`. This exposes the service on a cluster internal IP. The service is only reachable from within the cluster. 

## Ensure the ELB service role exists

In AWS accounts that have never created a load balancer before, it’s possible that the service role for ELB might not exist yet.

We can check for the role, and create it if it’s missing.

```bash
aws iam get-role --role-name "AWSServiceRoleForElasticLoadBalancing" || aws iam create-service-linked-role --aws-service-name "elasticloadbalancing.amazonaws.com"
```

## Ingress different options

`ALB`, Application Load Balancer, it's super popular to use for ingress, there's also a new otion for @mesh if you want to ingress directly into @mesh.

## Deploy frontend service

Let's bring up the Frontend

```bash
cd lc-front
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
``` 

We can check the progress by looking at the deployment status:

```bash
kubectl get deployemnt lc-front
``` 

We can check, that a new Load Balancer has been created, moving into the EC2 dashboard, and checking Load Balancers. We don't have to provision that, attach to the nodes, etc...K8s did for us. And he know, that is on AWS and where to look to achive this.

Currently this solution is pretty simple, but imagine that instead we have around 50 services, if we go on this kind of solution the price is going to increment dramatically, instead of exposing this 50 services, we can put an `ALB` Ingress controler, just a single entry point for al these services.

Be aware AL is L7 on OSI model, and only spports http and https, some kind of communication protocols are not supported. 

## Find the service address

Now that we have a running service that is `type: LoadBalancer` we need to find the ELB's address.

```bash
kubectl get service lc-front
```

or

```bash
kubectl get service lc-front -o wide
```

If we want to use the data programmatically, we can also output via json

```bash
ELB=$(kubectl get service lc-front -o json | jq -r '.status.loadBalancer.ingress[].hostname')

curl -m3 -v $ELB
```

> NOTE: It will take several minutes for ELB to become healthy and start passing traffic to the frontend pods.

### Scale the Backend Services

When we launched our services, we only launched one container of each. We can confirm this by viewing the running pods:

```bash
kubectl get deployments
```

Now let's scale up the backend services:

```bash
kubectl scale deployment lc-age-service --replicas=3
kubectl scale deployment lc-name-service --replicas=3
```

Confirm by looking at deployments again

### Scale up the frontend

```bash
kubectl get deployments
kubectl scale deployment lc-front --replicas=3
kubectl get deployments
```

### Differeneces between EKS and ECS

`eks` is one orchestartor per cluster and so issuing a command to it it can queue up that action and it can execute that action virtually immediately `ECS` on the other hand is an Orchestrator for the entire region so it is incredible massive scalable if you have to scale to thousands and thousands of nodes and hundreds of thousands of containers `ECS` can do it (no sweat), is something that Kubernetes can't do it today.

### Cleanup the applications

```bash
cd ./lc-front
kubectl delete -f kubernetes/service.yaml
kubectl delete -f kubernetes/deployment.yaml

cd ./lc-age-service
kubectl delete -f kubernetes/service.yaml
kubectl delete -f kubernetes/deployment.yaml

cd ./lc-name-service
kubectl delete -f kubernetes/service.yaml
kubectl delete -f kubernetes/deployment.yaml

```

## References

> Kubernetes deployment strategies: https://blog.container-solutions.com/kubernetes-deployment-strategies
> Kubernetes deplyment strategies by weave: https://www.weave.works/blog/kubernetes-deployment-strategies