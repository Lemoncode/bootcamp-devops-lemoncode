# ArgoCD en AKS

En este apartado vamos a instalar ArgoCD sobre un clúster de AKS usando la extensión de Azure descrita en la documentación oficial de Microsoft:

- https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/tutorial-use-gitops-argocd

La idea es que el repositorio Git sea la fuente de verdad y que ArgoCD despliegue automáticamente los manifiestos de la aplicación `tour-of-heroes` que ya tienes en:

- `04-cloud/00-aks/01-mi-primer-aks/manifests`

> Importante: en el momento de escribir este documento, la extensión de ArgoCD para AKS sigue en `preview`. Para entornos productivos Microsoft recomienda valorar Flux.

## Qué vamos a desplegar

Tus manifiestos están organizados en tres carpetas:

- `backend/`
- `db/`
- `frontend/`

Dentro de ellas tienes:

- Un `Deployment` para la API `tour-of-heroes-api`.
- Un `Deployment` para la base de datos SQL Server `tour-of-heroes-sql`.
- Un `Deployment` para el frontal `tour-of-heroes-web`.
- `Service` de tipo `LoadBalancer` para API y frontend.
- `Secret` para la conexión a SQL Server y la contraseña de `sa`.
- Un `PersistentVolumeClaim` para la base de datos.

Como los manifiestos están repartidos en subcarpetas, la aplicación de ArgoCD debe configurarse con despliegue recursivo.

## Prerrequisitos

Debes tener:

- Un clúster de AKS funcionando.
- Azure CLI actualizado.
- `kubectl` instalado.
- Permisos para gestionar el clúster y extensiones.

Si todavía no tienes definidas tus variables, puedes usar estas:

```bash
RESOURCE_GROUP="bootcamp-lemoncode"
AKS_NAME="lemoncode-cluster"
LOCATION="spaincentral"
```

Si tu clúster ya existe, no necesitas volver a crearlo. Solo asegúrate de tener el contexto descargado:

```bash
az aks get-credentials -g ${RESOURCE_GROUP} -n ${AKS_NAME} --overwrite-existing
kubectl get nodes
```

## Registrar proveedores necesarios

La documentación de Microsoft indica que debes registrar estos proveedores de recursos:

```bash
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.KubernetesConfiguration
az provider register --namespace Microsoft.Kubernetes
```

Puedes comprobar que el registro ha terminado correctamente con:

```bash
az provider show -n Microsoft.KubernetesConfiguration --query registrationState -o tsv
az provider show -n Microsoft.ContainerService --query registrationState -o tsv
az provider show -n Microsoft.Kubernetes --query registrationState -o tsv
```

El valor esperado es `Registered`.

## Instalar extensiones de Azure CLI

La guía oficial utiliza estas extensiones:

```bash
az extension add -n k8s-configuration
az extension add -n k8s-extension
```

Si ya las tienes instaladas, puedes actualizarlas:

```bash
az extension update -n k8s-configuration
az extension update -n k8s-extension
```

## Instalar la extensión de ArgoCD en AKS

La instalación más simple para AKS se hace con `az k8s-extension create`.

En el clúster que has creado en esta unidad se usó un único nodo, así que conviene desactivar `redis-ha`, ya que el modo HA por defecto requiere más nodos.

Ejecuta:

```bash
az k8s-extension create \
	--resource-group ${RESOURCE_GROUP} \
	--cluster-name ${AKS_NAME} \
	--cluster-type managedClusters \
	--name argocd \
	--extension-type Microsoft.ArgoCD \
	--release-train preview \
	--config "redis-ha.enabled=false" \
	--config "configs.params.application\.namespaces=argocd,tour-of-heroes"
```

Con esto Azure instalará ArgoCD en el namespace `argocd` y permitirá crear aplicaciones de ArgoCD en los namespaces `argocd` y `tour-of-heroes`.

Puedes comprobar el estado de la extensión con:

```bash
az k8s-extension show \
	--resource-group ${RESOURCE_GROUP} \
	--cluster-name ${AKS_NAME} \
	--cluster-type managedClusters \
	--name argocd
```

Y también revisando los pods:

```bash
kubectl get pods -n argocd
```

## Exponer la interfaz de ArgoCD

Si no tienes un Ingress Controller configurado, puedes publicar la UI de ArgoCD con un `LoadBalancer` como propone Microsoft:

```bash
kubectl -n argocd expose service argocd-server \
	--type LoadBalancer \
	--name argocd-server-lb \
	--port 80 \
	--target-port 8080
```

Después puedes consultar la IP pública:

```bash
kubectl get svc -n argocd argocd-server-lb
```

## Crear el namespace de la aplicación

Tus manifiestos están pensados para desplegarse juntos dentro de un mismo namespace. Crea el namespace antes de que ArgoCD sincronice la aplicación:

```bash
kubectl create namespace tour-of-heroes
```

## Crear la aplicación de ArgoCD para tus manifiestos

Ahora crea un recurso `Application` que apunte al repositorio y a la carpeta donde están tus manifiestos.

Como la carpeta `manifests/` contiene subdirectorios (`backend`, `db` y `frontend`), debes activar el modo recursivo con `directory.recurse: true`.

Sustituye `TU_REPO_URL` por la URL real de tu repositorio y, si hace falta, ajusta `targetRevision`.

```bash
kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
	name: tour-of-heroes
	namespace: argocd
spec:
	project: default
	source:
		repoURL: TU_REPO_URL
		targetRevision: master
		path: 04-cloud/00-aks/01-mi-primer-aks/manifests
		directory:
			recurse: true
	destination:
		server: https://kubernetes.default.svc
		namespace: tour-of-heroes
	syncPolicy:
		automated:
			prune: true
			selfHeal: true
		syncOptions:
			- CreateNamespace=true
EOF
```

> Nota: aunque aquí se incluye `CreateNamespace=true`, sigue siendo buena práctica crear el namespace previamente para dejar el flujo más explícito.

## Comprobar el despliegue

Una vez creada la `Application`, ArgoCD empezará a sincronizar los recursos del repositorio contra tu clúster.

Puedes comprobarlo con:

```bash
kubectl get application -n argocd
kubectl get all -n tour-of-heroes
kubectl get pvc -n tour-of-heroes
kubectl get secret -n tour-of-heroes
```

Si quieres observar el progreso:

```bash
watch kubectl get all -n tour-of-heroes
```

## Obtener las IPs públicas de la API y del frontend

Tus `Service` de frontend y backend son de tipo `LoadBalancer`, por lo que AKS les asignará IP pública.

Puedes obtenerlas con:

```bash
API_IP=$(kubectl get service tour-of-heroes-api -n tour-of-heroes -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
WEB_IP=$(kubectl get service tour-of-heroes-web -n tour-of-heroes -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo ${API_IP}
echo ${WEB_IP}
```

## Ajuste importante en tus manifiestos

Tu manifiesto de frontend tiene definida la variable `API_URL` con una IP fija:

```yaml
env:
	- name: API_URL
		value: http://20.23.122.26/api/hero
```

Eso significa que, aunque ArgoCD despliegue correctamente la aplicación, el frontal seguirá intentando llamar a esa IP concreta.

Para mantener un flujo GitOps correcto, cuando tengas la IP pública real de la API deberías actualizar el archivo `frontend/deployment.yaml` en Git y dejar algo parecido a esto:

```yaml
env:
	- name: API_URL
		value: http://<API_IP>/api/hero
```

Después haces commit y push al repositorio y ArgoCD aplicará el cambio automáticamente.

Si prefieres no depender de una IP pública para el frontend, otra opción más robusta es cambiarlo para que consuma el servicio interno de Kubernetes, siempre que la aplicación frontend pueda resolverlo correctamente.

## Actualizar la configuración de la extensión

Si más adelante necesitas actualizar parámetros de ArgoCD gestionados por la extensión, hazlo con Azure CLI y no tocando directamente los ConfigMaps, porque Azure podría sobrescribir los cambios.

Ejemplo:

```bash
az k8s-extension update \
	--resource-group ${RESOURCE_GROUP} \
	--cluster-name ${AKS_NAME} \
	--cluster-type managedClusters \
	--name argocd \
	--config "configs.cm.url=https://<ARGOCD_PUBLIC_IP>/auth/callback"
```

## Eliminar la extensión

Si quieres desinstalar ArgoCD del clúster:

```bash
az k8s-extension delete \
	-g ${RESOURCE_GROUP} \
	-c ${AKS_NAME} \
	-n argocd \
	-t managedClusters \
	--yes
```

## Resumen del flujo

1. Registrar proveedores de Azure.
2. Instalar o actualizar extensiones `k8s-configuration` y `k8s-extension`.
3. Instalar la extensión `Microsoft.ArgoCD` en el clúster AKS.
4. Exponer la UI de ArgoCD.
5. Crear la aplicación `Application` apuntando a la carpeta `04-cloud/00-aks/01-mi-primer-aks/manifests` con despliegue recursivo.
6. Verificar que ArgoCD sincroniza `backend`, `db` y `frontend` en `tour-of-heroes`.
7. Actualizar en Git el valor de `API_URL` del frontend con la IP real de la API para que el flujo GitOps quede completo.
