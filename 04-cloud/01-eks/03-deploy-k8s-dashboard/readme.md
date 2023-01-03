# Deploy the Kubernetes Dashboard 

## Deploy the Official Kubernetes Dashboard

The official Kubernetes dashboard is not deployed by default, but there are instructions in the official documentation

We can deploy the dashboard with the following command:

```bash
export DASHBOARD_VERSION="v2.0.0"
```

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/${DASHBOARD_VERSION}/aio/deploy/recommended.yaml
```

We get the following output:

```
namespace/kubernetes-dashboard created
serviceaccount/kubernetes-dashboard created
service/kubernetes-dashboard created
secret/kubernetes-dashboard-certs created
secret/kubernetes-dashboard-csrf created
secret/kubernetes-dashboard-key-holder created
configmap/kubernetes-dashboard-settings created
role.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrole.rbac.authorization.k8s.io/kubernetes-dashboard created
rolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
deployment.apps/kubernetes-dashboard created
service/dashboard-metrics-scraper created
deployment.apps/dashboard-metrics-scraper created
```

If we have a look into our services we can find

```bash
kubectl get services --all-namespaces
```

```
NAMESPACE              NAME                        TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)         AGE
default                kubernetes                  ClusterIP   10.100.0.1     <none>        443/TCP         3h15m
kube-system            kube-dns                    ClusterIP   10.100.0.10    <none>        53/UDP,53/TCP   3h15m
kubernetes-dashboard   dashboard-metrics-scraper   ClusterIP   10.100.90.15   <none>        8000/TCP        75s
kubernetes-dashboard   kubernetes-dashboard        ClusterIP   10.100.9.10    <none>        443/TCP         76s
```

## Access the Dashboard

Since this is deployed to our private cluster, we need to access it via a proxy. `kube-proxy` is available to proxy our requests to the dashboard service. In your workspace, run the following command:

```bash
kubectl proxy --port=8080 --address=0.0.0.0 --disable-filter=true &
```

> Running from a local environment is enough to do `kubectl proxy --port=8080` (or any other port that we want to use)

This will start the proxy, listen on port 8080, listen on all interface, and will filtering of non-localhost requests.

This command will continue to run in the background of the current terminal's session

Now we can access the Kubernetes Dashboard from

```
google localhost:8080/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

To access the dashboard we have to provide a `token`, we can achive this by running the following:

```bash
aws eks get-token --cluster-name lc-cluster | jq -r '.status.token'
```

Copy the output of this command and then click the radio button next to Token then in the text field below paste the output from the last command

## Cleanup

Stop the proxy and delete the dashboard deployment

```bash
# kill proxy
pkill -f 'kubectl proxy --port=8080'

# delete dashboard
kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/${DASHBOARD_VERSION}/aio/deploy/recommended.yaml

unset DASHBOARD_VERSION
```

## References

> How to use kubectl proxy to access your applications:  https://www.returngis.net/2019/04/como-usar-kubectl-proxy-para-acceder-a-tus-aplicaciones/
> Proxies in Kubernetes official documentation: https://kubernetes.io/docs/concepts/cluster-administration/proxies/