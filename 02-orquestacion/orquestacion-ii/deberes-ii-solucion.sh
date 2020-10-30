# Solución a los deberes.

# Tarea: 1 Verifica que la web está corriendo

# Mira que el pod esté corriendo:
kubectl get po web-1        # Tiene que aparecer READY 1/1 y STATUS Running

# Tarea 2: Verifica que puedes acceder al pod de la web directamente. ¿Funciona?

# Prueba con un port-forward para ver si puedes acceder
kubectl port-forward pod/web-1 3000:3000 
wget -qO- http://localhost:3000                 # Esto debería funcionar. La web está corriendo!


# Tarea 3. Verifica si puedes acceder a la web usando el servicio, desde dentro del cluster. ¿Funciona?

# Puedes hacerlo usando un pod de busybox:

kubectl run -it --rm bb --image busybox -- /bin/sh
# Aparece un terminal
wget -qO- http://web-1-svc:3000

# Esto no debería funcionar. Parece que el servicio está mal configurado.
# Obtén el YAML del servicio
kubectl get svc web-1-svc -o yaml

# Observa spec.port. Parece que el servicio está escuchando por el puerto 80.
# Vamos a arreglar eso

# Borramos el servicio
kubectl delete svc web-1-svc
# Exponemos el pod de nuevo
kubectl expose pod web-1 --port 3000 --name web-1-svc

# Probamos de nuevo
kubectl run -it --rm bb --image busybox -- /bin/sh
# Aparece un terminal
wget -qO- http://web-1-svc:3000

# Ahora debería funcionar!!! :)
