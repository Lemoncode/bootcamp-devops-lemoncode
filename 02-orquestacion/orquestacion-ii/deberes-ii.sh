# Escenario 1: La web inaccessible

# En este escenario te propongo que averigües y soluciones un problema de una web desplegada en Kubernetes.
# La web corre en un pod llamado web-1 y hay un servicio creado llamado web-1-svc. Por algún motivo no se puede acceder
# a la web, desde dentro del cluster.
# No está claro si el pod funciona o no, o el servicio está bien configurado.

# NOTA: No es necesario acceder DESDE FUERA del cluster, para verificar accesos usa un pod temporal de busybox

# Tareas:

# 1. Verifica que la web está corriendo
# 2. Verifica que puedes acceder al pod de la web directamente. ¿Funciona?
# 3. Verifica si puedes acceder a la web usando el servicio, desde dentro del cluster. ¿Funciona?
# 4. Arregla los errores

# Para empezar ejecuta el fichero escenario-2-1.yaml


