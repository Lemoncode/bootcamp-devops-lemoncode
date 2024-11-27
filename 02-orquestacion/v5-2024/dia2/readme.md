# Dia 2: Servicios y ReplicaSets

En este día introdujimos dos elementos fundamentales: los servicios y los replicasets.

- Los replicasets garantizan que en todo momento haya N pods idénticos ejecutándose
- Los servicios exponen los pods a otros pods (clusterip) o al exterior (nodeport/loadbalancer). Al ser los pods elementos transitorios, los servicios garantizan una IP (y DNS) estable para uno o más pods.