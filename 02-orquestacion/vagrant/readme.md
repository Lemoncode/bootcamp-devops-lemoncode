## Install a pod network

```bash
kubectl apply -f https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')
```

## Allow nodes to run on the master node

```bash
kubectl taint nodes --all node-role.kubernetes.io/master-
```