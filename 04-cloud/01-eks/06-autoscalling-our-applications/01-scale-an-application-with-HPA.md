# Scale an aplication with HPA

## Configure Horizontal Pod Autoscaler (HPA)

### Deploy the Metrics Server

Metrics Server is a scalable, efficient source of container resource metrics for Kubernetes built-in autoscaling pipelines.

These metrics will drive the scaling behavior of the *deployments*.

We will deploy the metrics server using [Kubernetes Metrics Server](https://github.com/kubernetes-sigs/metrics-server).

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.1/components.yaml
```

Lets' verify the status of the metrics-server APIService (it could take a few minutes).

```bash
kubectl get apiservice v1beta1.metrics.k8s.io -o json | jq '.status'
```

We expect an output similar to this:

```json
{
  "conditions": [
    {
      "lastTransitionTime": "2020-12-21T15:42:43Z",
      "message": "all checks passed",
      "reason": "Passed",
      "status": "True",
      "type": "Available"
    }
  ]
}
```

**We are now ready to scale a deployed application**

A new `addon` is set in our system we can check by running:

```bash
kubectl get pods -n kube-system
```


## Deploy a Sample App

We will deploy an application and expose as a service on TCP port 80.

The application is a custom-built image based on the php-apache image. The index.php page performs calculations to generate CPU load. More information can be found [here](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/#run-expose-php-apache-server)

```bash
kubectl create deployment php-apache --image=us.gcr.io/k8s-artifacts-prod/hpa-example
kubectl set resources deploy php-apache --requests=cpu=200m
kubectl expose deploy php-apache --port 80

kubectl get pod -l app=php-apache

```

## Create an HPA resource

This HPA scales up when CPU exceeds 50% of the allocated container resource.

```bash
kubectl autoscale deployment php-apache `#The target average CPU utilization` \
    --cpu-percent=50 \
    --min=1 `#The lower limit for the number of pods that can be set by the autoscaler` \
    --max=10 `#The upper limit for the number of pods that can be set by the autoscaler`

```

View the HPA using kubectl. You probably will see <unknown>/50% for 1-2 minutes and then you should be able to see 0%/50%

```bash
kubectl get hpa
``` 

## Generate load to trigger scaling

**Open a new terminal**

```bash
kubectl run -it --rm --restart=Never busybox --image=gcr.io/google-containers/busybox sh
```


> Reference: https://medium.com/better-programming/kubernetes-tips-create-pods-with-imperative-commands-in-1-18-62ea6e1ceb32

Execute a while loop to continue getting http://php-cache

```bash
while true; do wget -q -O - http://php-apache; done
``` 
* **-q** quiet no output on conosole
* **-O** dump results into a file


In the previous tab, watch the HPA with the following command

```bash
kubectl get hpa -w

```

You can now stop (Ctrl + C) load test that was running in the other terminal. You will notice that HPA will slowly bring the replica count to min number based on its configuration. You should also get out of load testing application by pressing Ctrl + D.