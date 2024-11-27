# Dia 6

Hablamos de como k8s gestiona los recursos (las peticiones y los límites).

Recordad las "reglas de oro":

1. Peticiones lo más pequeñas posibles (para que nuestro pod quepa en más nodos)
2. La diferencia entre límites y peticiones lo más pequeña posible (para que sea más dificil desalojar nuestro pod). Si limites == peticiones k8s nos garantiza que NO nos desaloja.

Para ajustar límites y petciones la solución es "medir" nuestra aplicación con cargas similares a las esperadas.

Luego hablamos del scheduler y de como lo podemos influenciar (nodeselector, taints, tolerations, afinidades, ...)