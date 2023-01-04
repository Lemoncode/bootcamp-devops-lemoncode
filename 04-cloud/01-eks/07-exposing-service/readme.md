# Using a Network Load Balancer with the NGINX Ingress controller on Amazon EKS

## Kubernetes Ingress

Is an API object that provides a collection of routing rules that govern how external/internal users access Kubernetes services running in a cluster. An ingress controller is responsible for reading the ingress resource information and processing it appropriately.

## What is a Network Load Balancer?

An AWS Network Load Balancer functions ath the fourth layer of the Open Systems Interconnection (OSI) model. It can handle millions of requests per second. After the load balancer receives a connection request, it selects a target from the target group for the default rule. It attempts to open a TCP connection to the selected target on the port specified in the listener configuration.

## Exposing your application on Kubernetes

Ingress is not a service type, but it acts as the entry point for your cluster. It lets you consolidate your routing rules into a single resource, as it can expose multiple services under the same IP address.

Kubernetes supports a high-level abstraction called Ingress, which allows simple host- or URL-based HTTP routing. An Ingress is a core concept of Kubernetes. It is always implemented by a third party proxy; these implementations are know as ingress controllers. An ingress controller is responsible for reading the ingress resource information and processing data accordingly. 

An Ingress controller is a DaemonSet or Deployment, deployed as Kubernetes Pod, that watches the endpoint of the API server for updates to the Ingress resource. Its job is to satisfy requests for Ingresses.

## Why do I need a load balancer in front of an ingress?

Ingress is tightly integrated into Kubernetes, meaning that your existing workflows around `kubectl` will likely extend nicely to managing ingress. An Ingress controller does not tipically eliminate the need for an external load blancer, it simply adds an additional layer of routing and control behind the load balancer.

Pods and nodes are not guaranteed to live for the whole lifetime that the user intends: pods are ephemeral and vulnerable to kill signals from Kubernetes during occassion such as:

* Scalling
* Memory or CPU sturation
* Rescheduling for more efficient reource use
* Downtime due to outside factors

The load balancer (Kubernetes service) is a construct that stands as a single, fixed-service endpoint for a given set of pods or worker nodes. To take advantage of the previously-discussed benefits of a Network Load Balancer (NLB), we create a Kubernetes service of `type:loadbalancer` with the NLB annotations, and this load balancer sits in front of the ingress controller – which is itself a pod or a set of pods. In AWS, for a set of EC2 compute instances managed by an Autoscaling Group, there should be a load balancer that acts as both a fixed referable address and a load balancing mechanism.

## How to use a Network Load Balancer with the NGINX Ingress resource in Kubernetes

### Step 1. Create the mandatory resources for NGINX Ingress in your cluster:

This will create the `nginx-ingress` and the `network load balancer`

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.49.3/deploy/static/provider/aws/deploy.yaml
``` 

Create `apple.deploy.yaml`

```yaml
kind: Pod
apiVersion: v1
metadata:
  name: apple-app
  labels:
    app: apple
spec:
  containers:
    - name: apple-app
      image: hashicorp/http-echo
      args:
        - "-text=apple"

---
kind: Service
apiVersion: v1
metadata:
  name: apple-service
spec:
  selector:
    app: apple
  ports:
    - port: 5678

```

Create `banana.deploy.yaml`

```yaml
kind: Pod
apiVersion: v1
metadata:
  name: banana-app
  labels:
    app: banana
spec:
  containers:
    - name: banana-app
      image: hashicorp/http-echo
      args:
        - "-text=banana"

---
kind: Service
apiVersion: v1
metadata:
  name: banana-service
spec:
  selector:
    app: banana
  ports:
    - port: 5678

```


Create some services

```bash
kubectl apply -f ./apple.deploy.yaml 
```

```bash
kubectl apply -f ./banana.deploy.yaml
``` 

## Step 2. Defining the Ingress resource to route traffic to the services created above

Now declare an Ingress to route requests to `/apple` to the first service, and requests to `/banana` to second service. Create `fruits.ingress.yml`

```yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - host: "jaimesalas.com"
    http:
      paths:
      - pathType: Prefix
        path: "/apple"
        backend:
          service:
            name: apple-service
            port:
              number: 5678
      - pathType: Prefix
        path: "/banana"
        backend:
          service:
            name: banana-service
            port:
              number: 5678
```

Note that we're using an annotation for `ingress.class`, since it's not set as the default one, we have to use the `annotation`. You can check this [link](https://stackoverflow.com/questions/65289827/nginx-ingress-controller-not-working-on-amazon-eks) on stackoverflow.

And apply to our cluster

```bash
kubectl apply -f fruits.ingress.yml
```

Now to check that our ingress is working we need the `dns` of NLB that we have created, the easiest way to do this is run:

```bash
kubectl get ingress
```

We get something simiar to this:

```
NAME              CLASS    HOSTS            ADDRESS                                                                         PORTS   AGE
example-ingress   <none>   jaimesalas.com   a2e47070555144b06a0cd99a242d6753-ef17945a5e983c95.elb.eu-west-3.amazonaws.com   80      39m
```
The above adress is the `NLB` resource that's forwarding traffic to the ingress controller, if we run the following

**-I** the response only contains the headers

```bash
curl -I  http://a2e47070555144b06a0cd99a242d6753-ef17945a5e983c95.elb.eu-west-3.amazonaws.com
```

We get the following response

```
HTTP/1.1 404 Not Found
Server: nginx/1.17.10
Date: Wed, 16 Dec 2020 16:53:31 GMT
Content-Type: text/html
Content-Length: 154
Connection: keep-alive
```

> NOTE: The default server returns a "Not Found" page with 404 status code for all the requests for domains where no Ingress rules are defined. The Ingress Controller, based on the defined rules, doesn't divert traffic to the specified backend service, unless the request matches with the configuration.

Beacuse the **host** field is configured for the Ingress object, you must supply the **Host** header of the request with the same `hostname`

```bash
curl -I -H "Host: jaimesalas.com" http://a2e47070555144b06a0cd99a242d6753-ef17945a5e983c95.elb.eu-west-3.amazonaws.com/apple/
``` 

And now we get the following result

```
HTTP/1.1 200 OK
Server: nginx/1.17.10
Date: Wed, 16 Dec 2020 17:07:35 GMT
Content-Type: text/plain; charset=utf-8
Content-Length: 6
Connection: keep-alive
X-App-Name: http-echo
X-App-Version: 0.2.3
```

## Step 3. Clean up 

Deelete Ingress resource

```bash
kubectl delete -f fruits.ingress.yml
``` 

Delete services

```bash
kubectl delete -f ./apple.deploy.yaml 
kubectl delete -f ./banana.deploy.yaml
```

Delete NGINX Ingress Controller and NLB

```bash
kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.49.3/deploy/static/provider/aws/deploy.yaml
```

Delete the cluster

```bash
eksctl delete cluster --name=lc-cluster
```