# GitOps con ArgoCD en AKS

En esta unidad vamos a montar [ArgoCD](https://argo-cd.readthedocs.io/) sobre tu clúster de AKS para que el repositorio Git sea la fuente de verdad y ArgoCD despliegue automáticamente los manifiestos de la aplicación `tour-of-heroes` que ya tienes en [01-mi-primer-aks/manifests](../01-mi-primer-aks/manifests).

Para ello usaremos la extensión oficial de Azure descrita en la [documentación de Microsoft](https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/tutorial-use-gitops-argocd).

> ⚠️ **Nota importante**: En el momento de escribir este documento, la extensión de ArgoCD para AKS sigue en `preview`. Para entornos productivos Microsoft recomienda valorar Flux.

## Prerequisitos

Si ya tienes un clúster de AKS funcionando de las unidades anteriores, solo asegúrate de tener las variables de entorno definidas y el contexto descargado:

```bash
RESOURCE_GROUP="bootcamp-lemoncode"
AKS_NAME="lemoncode-cluster"
LOCATION="spaincentral"
```

```bash
az aks get-credentials -g ${RESOURCE_GROUP} -n ${AKS_NAME} --overwrite-existing
kubectl get nodes
```

Si todavía no tienes clúster, puedes crearlo siguiendo los pasos de [01-mi-primer-aks](../01-mi-primer-aks/README.md).

# Instalar ArgoCD en AKS

Lo primero que necesitas es registrar los proveedores de recursos de Azure que hacen falta para trabajar con extensiones de Kubernetes:

```bash
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.KubernetesConfiguration
az provider register --namespace Microsoft.Kubernetes
```

Puedes comprobar que el registro ha terminado con:

```bash
az provider show -n Microsoft.KubernetesConfiguration --query registrationState -o tsv
az provider show -n Microsoft.ContainerService --query registrationState -o tsv
az provider show -n Microsoft.Kubernetes --query registrationState -o tsv
```

Cuando todos devuelvan `Registered`, ya puedes continuar.

Ahora instala las extensiones de Azure CLI que necesitas:

```bash
az extension add -n k8s-configuration
az extension add -n k8s-extension
```

Si ya las tenías instaladas, actualízalas:

```bash
az extension update -n k8s-configuration
az extension update -n k8s-extension
```

¡Ahora sí! Ya puedes instalar ArgoCD en tu clúster. Como en esta unidad estamos usando un único nodo, desactivamos `redis-ha` (el modo HA necesita más nodos):

```bash
az k8s-extension create \
-g ${RESOURCE_GROUP} \
-c ${AKS_NAME} \
-t managedClusters \
--name argocd \
--extension-type Microsoft.ArgoCD \
--release-train preview \
--config "redis-ha.enabled=false" \
--config "configs.params.application\.namespaces=argocd,tour-of-heroes"
```

Azure instalará ArgoCD en el namespace `argocd` y permitirá crear aplicaciones en `argocd` y `tour-of-heroes`.

Para comprobar que todo ha ido bien:

```bash
az k8s-extension show -g ${RESOURCE_GROUP} -c ${AKS_NAME} -t managedClusters --name argocd
kubectl get pods -n argocd
```

Cuando todos los pods estén en `Running`, ya tienes ArgoCD listo 🎉

# Acceder a la UI de ArgoCD

Lo siguiente es exponer la interfaz web de ArgoCD. Si no tienes un Ingress Controller configurado, lo más rápido es crear un `LoadBalancer`:

```bash
kubectl -n argocd expose service argocd-server \
--type LoadBalancer \
--name argocd-server-lb \
--port 443 \
--target-port 8080
```

> ⚠️ **Importante**: ArgoCD sirve HTTPS (TLS) en el puerto 8080, por eso exponemos el puerto 443. Si usaras el puerto 80 tendrías timeout porque el navegador envía HTTP plano a un servidor que espera TLS.

Espera a que Azure le asigne una IP pública:

```bash
kubectl get svc -n argocd argocd-server-lb
```

Cuando tengas la `EXTERNAL-IP`, ya puedes acceder a `https://<IP>` desde tu navegador (acepta el certificado autofirmado).

## Credenciales de acceso

El usuario por defecto es `admin`. La contraseña inicial está en un Secret:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d && echo
```

> 🔒 Por seguridad, se recomienda cambiar esta contraseña después del primer acceso o eliminar el Secret.

Una vez que inicies sesión verás una pantalla como esta:

![UI de ArgoCD](images/UI%20ArgoCD.png)

# Desplegar Tour of Heroes con ArgoCD

Ahora viene lo interesante: vamos a hacer que ArgoCD despliegue automáticamente la aplicación Tour of Heroes desde los manifiestos que ya tienes en el repositorio.

Los manifiestos están organizados en tres carpetas (`backend/`, `db/` y `frontend/`), así que tendremos que activar el modo recursivo en ArgoCD.

## Opción 1: Desde la UI de ArgoCD

Haz clic en el botón `New App` y rellena los campos:

**Primera parte** - Nombre y proyecto:

![Crear aplicación - Parte 1](images/Crear%20aplicación%20-%20Parte%201.png)

**Segunda parte** - Repositorio y destino. Indica la URL del repo, la rama `master` y la carpeta `04-cloud/00-aks/01-mi-primer-aks/manifests`. Como destino usa `https://kubernetes.default.svc` (el mismo clúster) y el namespace `tour-of-heroes`:

![Crear aplicación - Parte 2](images/Crear%20aplicación%20-%20Parte%202.png)

**Tercera parte** - ¡No olvides marcar `Recursive`! Sin esto ArgoCD no entrará en las subcarpetas:

![Crear aplicación - Parte 3](images/Crear%20aplicación%20-%20Parte%203.png)

Cuando pulses `Create` verás un mapa con todos los recursos que se van a desplegar, pero todavía no estarán aplicados. Para eso pulsa `Sync` y confirma la acción.

## Opción 2: Desde kubectl

Si prefieres hacerlo por línea de comandos, aplica este manifiesto:

```bash
kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: tour-of-heroes-desde-kubectl
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/Lemoncode/bootcamp-devops-lemoncode
    targetRevision: master
    path: 04-cloud/00-aks/01-mi-primer-aks/manifests
    directory:
      recurse: true
  destination:
    server: https://kubernetes.default.svc
    namespace: tour-of-heroes-desde-kubectl
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF
```

Con `syncPolicy.automated` ArgoCD sincronizará automáticamente cada vez que detecte cambios en Git. `prune: true` eliminará recursos que ya no estén en el repo y `selfHeal: true` revertirá cambios manuales en el clúster.

# Comprobar el despliegue

Una vez creada la `Application`, ArgoCD empezará a sincronizar. Puedes ver el estado con:

```bash
kubectl get application -n argocd
```

Y si quieres ver cómo van apareciendo los recursos:

```bash
watch kubectl get all -n tour-of-heroes-desde-kubectl
```

Cuando todo esté desplegado, recupera las IPs públicas de la API y el frontend:

```bash
API_IP=$(kubectl get service tour-of-heroes-api -n tour-of-heroes-desde-kubectl -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
WEB_IP=$(kubectl get service tour-of-heroes-web -n tour-of-heroes-desde-kubectl -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo http://${API_IP}/api/hero
echo http://${WEB_IP}
```

## ⚠️ Ajuste importante: la variable API_URL

El manifiesto del frontend tiene la variable `API_URL` con una IP fija. Eso significa que aunque ArgoCD despliegue correctamente la aplicación, el frontal seguirá intentando llamar a esa IP concreta.

Para que el flujo GitOps quede completo, actualiza el archivo `frontend/deployment.yaml` en Git con la IP real de tu API:

```yaml
env:
  - name: API_URL
    value: http://<TU_API_IP>/api/hero
```

Haz commit, push, y ArgoCD aplicará el cambio automáticamente. ¡Así es como funciona GitOps! 🚀

# Gestionar ArgoCD

## Actualizar la configuración

Si necesitas cambiar parámetros de ArgoCD gestionados por la extensión, hazlo siempre con Azure CLI (no toques los ConfigMaps directamente porque Azure podría sobrescribirlos):

```bash
az k8s-extension update \
-g ${RESOURCE_GROUP} \
-c ${AKS_NAME} \
-t managedClusters \
--name argocd \
--config "configs.cm.url=https://<ARGOCD_PUBLIC_IP>/auth/callback"
```

## Desinstalar ArgoCD

Si quieres eliminar ArgoCD del clúster:

```bash
az k8s-extension delete \
-g ${RESOURCE_GROUP} \
-c ${AKS_NAME} \
-n argocd \
-t managedClusters \
--yes
```
