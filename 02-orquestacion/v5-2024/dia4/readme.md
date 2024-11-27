# Dia 4: Statefulsets y almacenamiento persistente

Dedicamos el día casi entero a hablar sobre el almacenamiento persistente y los statefulsets para el despliegue de apps con estado.

Recordad los conceptos básicos:

- Provider: Se instalan en el clúster (antiguamente era código de K8S ahora son pods usando CSI) y gestionan sistemas de almacenamiento (discos virtuales, AWS EBS, Azure Blobs, ... )
- StorageClass: Representa un provider con unos ciertos parámetros (un disco virtual SSD o Premium o ...). Permite aprovisionar volúmenes persistentes automáticamente.
- PersistentVolume: La representación dentro de k8s de un sistema de almacenamiento externo. Puede ser creado por el admin del clúster o bien automáticamente (aprovisionamiento dinámico)
- PersistentVolumeClaim: La representación de un pod pidiendo un volumen persistente con unas determinadas características. La relación del PVC con el PV es de 1:1

El StatefulSet además de la plantilla de pod, tiene una plantilla de PVCs para asegurar que cada pod tiene su propio PVC y por lo tanto su propio PV único.
