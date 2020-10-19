cd contenedores-ii
# 1. Crear una imagen con un servidor web Apache y el mismo contenido que en la carpeta content (fijate en el Dockerfile con el que cree simple-nginx)
docker build . -t simple-apache
# 2. Ejecutar un contenedor con mi nueva imagen
docker run -d --name myapache -p 8080:80 simple-apache:1.0
# 3. Averiguar cuántas capas tiene mi nueva imagen
docker inspect simple-apache:1.0 #En el apartado "Layers" pueden contarse cuántas capas hay
docker history simple-apache:1.0 #Todas las acciones que son < 0B son capas