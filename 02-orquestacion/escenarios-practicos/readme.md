# Ejercicios de Kubernetes

Venga! Os propongo algunos ejercicios de Kuberentes para ir "engrasando la máquina :D". Para hacerlo divertido serán ejercicios prácticos.

Cada carpeta tiene:

- Un `readme.md` que describe el escenario
- Unos yamls que crean el escenario

La forma de proceder es sencilla:

- Con el terminal os colocáis en la carpeta del ejercicio a realizar (`cd <carpeta-ejercicio>`)
- Creais el escenario: `kubectl apply -f .`
- Leeis el fichero `readme.md` e intentais resolver el escenario.
- Una vez resuelto elimináis el escenario (`kubectl delete ns ejercicio`)

** Todos los ejercicios se ejecutan en el espacio de nombres `ejercicio`.** Por lo tanto...

- Acuérdate de añadir `-n ejercicio` en todos tus comandos de `kubectl` o bien...
- Cambia tu contexto para acceder al namespace `ejercicio` de forma automática: `kubectl config set-context --current --namespace ejercicio`
- Elimina el namespace ejercicio al finalizar, para dejar todo limpio (`kubectl delete ns ejercicio`)

## Si necesitáis alguna ayuda podéis...

- Mirar los ficheros YAML del ejercicio por si os dan una pista. **Aunque es posible resolverlo todo sin mirar los YAML**
- Mirar el fichero `pistas.md` de cada ejercicio.
- **Dejar un mensaje en Slack :)**

Y, para terminar, algunas pistas generales:

- Recordad que podéis obtener el YAML de un comando imperativo mediante los modificadores `--dry-run -o yaml` en kubectl (p. ej. `kubectl run bb --image busybox --dry-run -o yaml > pod_bb.yaml`)
- Recordad que podéis obtener el YAML de un objeto existente mediante el comando `kubectl get <tipo> <nombre> -o yaml` (p. ej. `kubectl get pod my-pod -o yaml > my_pod.yaml`). En este caso el YAML obtenido tiene más campos que los que usaríamos nosotros al crearlo ya que es la descripción entera que tiene el cluster (incluyendo valores por defecto y campos de solo lectura como `status`).

**Cualquier duda la podéis comentar en Slack!!!**

