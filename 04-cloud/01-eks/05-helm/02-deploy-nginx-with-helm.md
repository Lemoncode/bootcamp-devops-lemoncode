# Deploy nginx with Helm

## Update the Chart Repository

Helm uses a packaging format called [Charts](https://helm.sh/docs/topics/charts/). A Chart is a collection of files and templates that describes Kubernetes resources.

Charts can be simple, describing something like a standalone web server (which is what we are going to create), but they can also be more complex, for example, a chart that represents a full web application stack, including web servers, databases, proxies, etc.

Instead of installing Kubernetes resources manually via `kubectl`, one can use Helm to install pre-defined Charts faster, with less chance of typos or other operator errors.

Chart repositories change frequently due to updates and new additions. To keep Helm’s local list updated with all these changes, we need to occasionally run the [repository update](https://helm.sh/docs/helm/helm_repo_update/) command.

To update Helm's local list of Charts, run:

```bash
# first, add the default repository, then update
helm repo add stable https://charts.helm.sh/stable
helm repo update

``` 

## Search Chart Repositories

Now that our repository Chart list has been updated, we can [search for Charts](https://helm.sh/docs/helm/helm_search/)

To list all Charts:

```bash
helm search repo
```

You can see from the output that it dumped the list of all Charts we have added. In some cases that may be useful, but an even more useful search would involve a keyword argument. So next, we’ll search just for nginx:

```bash
helm search repo nginx
```

The results in:

```
NAME                            CHART VERSION   APP VERSION     DESCRIPTION                                       
stable/nginx-ingress            1.41.3          v0.34.1         DEPRECATED! An nginx Ingress controller that us...
stable/nginx-ldapauth-proxy     0.1.6           1.13.5          DEPRECATED - nginx proxy with ldapauth            
stable/nginx-lego               0.3.1                           Chart for nginx-ingress-controller and kube-lego  
stable/gcloud-endpoints         0.1.2           1               DEPRECATED Develop, deploy, protect and monitor...
```

This new list of Charts are specific to nginx, because we passed the **nginx** argument to the `helm search repo` command.

> Reference: https://helm.sh/docs/helm/helm_search_repo/

## Add the Bitnami Repository

We saw that nginx offers many different products via the default Helm Chart repository, but the nginx standalone web server is not one of them.

After a quick web search, we discover that there is a Chart for the nginx standalone web server available via the [Bitnami Chart repository](https://github.com/bitnami/charts/tree/master/bitnami).


```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
```

Once that completes, we can search all Bitnami Charts:

```bash
helm search repo bitnami

```

Search once again for nginx

```bash
helm search repo nginx
```

Now we are seeing more nginx options, across both repositories:

```
bitnami/nginx                           8.2.3           1.19.6          Chart for the nginx server                        
bitnami/nginx-ingress-controller        7.0.5           0.41.2          Chart for the nginx Ingress controller            
stable/nginx-ingress                    1.41.3          v0.34.1         DEPRECATED! An nginx Ingress controller that us...
```

Or even search the Bitnami repo, just for nginx:

```bash
helm search repo bitnami/nginx

```

## Install bitnami/nginx

Installing the Bitnami standalone nginx web server Chart involves us using the [helm install](https://helm.sh/docs/helm/helm_install/) command.

A Helm Chart can be installed multiple times inside a Kubernetes cluster. This is because each installation of a Chart can be customized to suit a different purpose.

For this reason, you must supply a unique name for the installation, or ask Helm to generate a name for you.

```bash
helm install mywebserver bitnami/nginx --dry-run
```

Now to really install nginx on our cluster, we can run:

```bash
helm install mywebserver bitnami/nginx
```

The output is simillar to this

```bash
NAME: mywebserver
LAST DEPLOYED: Mon Dec 21 15:45:05 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
** Please be patient while the chart is being deployed **

NGINX can be accessed through the following DNS name from within your cluster:

    mywebserver-nginx.default.svc.cluster.local (port 80)

To access NGINX from outside the cluster, follow the steps below:

1. Get the NGINX URL by running these commands:

  NOTE: It may take a few minutes for the LoadBalancer IP to be available.
        Watch the status with: 'kubectl get svc --namespace default -w mywebserver-nginx'

    export SERVICE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].port}" services mywebserver-nginx)
    export SERVICE_IP=$(kubectl get svc --namespace default mywebserver-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    echo "http://${SERVICE_IP}:${SERVICE_PORT}"
```

In order to review the underlying Kubernetes services, pods and deployments, run:

```bash
kubectl get svc,po,deploy
```

We get something similar to this:

```
NAME                        TYPE           CLUSTER-IP     EXTERNAL-IP                                                              PORT(S)        AGE
service/kubernetes          ClusterIP      10.100.0.1     <none>                                                                   443/TCP        136m
service/mywebserver-nginx   LoadBalancer   10.100.9.232   a7130a0207757453594c4cb5bdf072e5-381544302.eu-west-3.elb.amazonaws.com   80:31519/TCP   2m38s

NAME                                     READY   STATUS    RESTARTS   AGE
pod/mywebserver-nginx-857766d4fd-9tdwf   1/1     Running   0          2m37s

NAME                                READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/mywebserver-nginx   1/1     1            1           2m38s
```

The first object shown in this output is a Deployment. A Deployment object manages rollouts (and rollbacks) of different versions of an application.

You can inspect this Deployment object in more detail by running the following command:

```bash
kubectl describe deployment mywebserver
```

The next object shown created by the Chart is a Pod. A Pod is a group of one or more containers.

To verify the Pod object was successfully deployed, we can run the following command:

```bash
kubectl get pods -l app.kubernetes.io/name=nginx
```

We can check that the container inside the pod is running:

```
NAME                                 READY   STATUS    RESTARTS   AGE
mywebserver-nginx-857766d4fd-9tdwf   1/1     Running   0          4m48s
```

The third object that this Chart creates for us is a Service. A Service enables us to contact this nginx web server from the Internet, via an Elastic Load Balancer (ELB).

To get the complete URL of this Service, run:

```bash
kubectl get service mywebserver-nginx -o wide
```

```
NAME                TYPE           CLUSTER-IP     EXTERNAL-IP                                                              PORT(S)        AGE     SELECTOR
mywebserver-nginx   LoadBalancer   10.100.9.232   a7130a0207757453594c4cb5bdf072e5-381544302.eu-west-3.elb.amazonaws.com   80:31519/TCP   6m22s   app.kubernetes.io/instance=mywebserver,app.kubernetes.io/name=nginx
```

Copy the value for EXTERNAL-IP, open a new tab in your web browser, and paste it in.

## Clean up

To remove all the objects that the Helm Chart create we can use [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/)

Before we uninstall our application, we can verify what we have running via the [helm list](https://helm.sh/docs/helm/helm_list/) command:

```bash
helm list
```

```
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/lemoncode/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/lemoncode/.kube/config
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
mywebserver     default         1               2020-12-21 15:45:05.835403883 +0100 CET deployed        nginx-8.2.3     1.19.6 
```

To uninstall:

```bash
helm uninstall mywebserver

```

kubectl will also demonstrate that our pods and service are no longer available:

```bash
kubectl get pods -l app.kubernetes.io/name=nginx
kubectl get service mywebserver-nginx -o wide

``` 