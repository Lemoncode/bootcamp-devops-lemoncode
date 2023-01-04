# Install Kube-ops-view

Before starting to learn about the various auto-scaling options for your EKS cluster we are going to install Kube-ops-view.

Kube-ops-view provides a common operational picture for a Kubernetes cluster that helps with understanding our cluster setup in a visual way.

> Note: helm must be installed

The following line updates the stable helm repository and then installs kube-ops-view using a LoadBalancer Service type and creating a RBAC (Resource Base Access Control) entry for the read-only service account to read nodes and pods information from the cluster.

```bash
helm install kube-ops-view \
stable/kube-ops-view \
--set service.type=LoadBalancer \
--set rbac.create=True
```

The execution above installs kube-ops-view exposing it through a Service using the LoadBalancer type. A successful execution of the command will display the set of resources created and will prompt some advice asking you to use `kubectl proxy` and a local URL for the service. Given we are using the type LoadBalancer for our service, we can disregard this; Instead we will point our browser to the external load balancer.

> Monitoring and visualization shouldn’t be typically be exposed publicly unless the service is properly secured and provide methods for authentication and authorization. You can still deploy kube-ops-view using a Service of type ClusterIP by removing the --set service.type=LoadBalancer section and using kubectl proxy. Kube-ops-view does also support Oauth 2

To check the chart was installed successfully:

```bash
helm list
``` 

```
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/lemoncode/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/lemoncode/.kube/config
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
kube-ops-view   default         1               2020-12-21 16:29:18.677926812 +0100 CET deployed        kube-ops-view-1.2.4     20.4.0    
```

With this we can explore kube-ops-view output by checking the details about the newly service created.

```bash
kubectl get svc kube-ops-view | tail -n 1 | awk '{ print "Kube-ops-view URL = http://"$4 }'
```

This will display a line similar to Kube-ops-view URL = http://<URL_PREFIX_ELB>.amazonaws.com Opening the URL in your browser will provide the current state of our cluster.

> Reference: https://kubernetes-operational-view.readthedocs.io/en/latest/

## Alternative installation

```bash
helm repo add christianknell https://christianknell.github.io/helm-charts
helm repo update
```

```bash
helm install kube-ops-view \
 christianknell/kube-ops-view \
 --set service.type=LoadBalancer
```

