#Deberes:
# 1. Crear un contenedor con MongoDB, protegido con usuario y contraseña, añadir una colección, crear un par de documentos y acceder a ella a través de MongoDB Compass
    # Pasos:
    # - Localizar la imagen en Docker Hub para crear un MongoDB
docker search mongo
https://hub.docker.com/_/mongo
    # - Ver qué parámetros necesito para crearlo

# Mac #

docker run -d --name some-mongo \
    -p 27017:27017 \
    -e MONGO_INITDB_ROOT_USERNAME=mongoadmin \
    -e MONGO_INITDB_ROOT_PASSWORD=secret \
    mongo

# docker exec -it some-mongo mongosh --username mongoadmin --password secret
# Desde Compass conectate a tu nuevo MongoDB. Haz clic en la opción Fill in connection fields individually y añade los valores:
# hostname: localhost
# port: 27017
# Authentication: Username and Password
# Las credenciales que hayas puesto
# y haz clic en conectar

#Crea una base de datos que se llame Library y una colección llamada Books. 
# Accede a ella e importa el archivo llamado books.json que se encuentra en el directorio de este ejercicio.
# - Ver los logs de tu nuevo mongo
docker logs some-mongo


# 2. Servidor Nginx
#    - Crea un servidor Nginx llamado lemoncoders-web y copia el contenido de la carpeta lemoncoders-web en la ruta que sirve este servidor web. 
#    - Ejecuta dentro del contenedor la acción ls, para comprobar que los archivos se han copiado correctamente.
#    - Hacer que el servidor web sea accesible desde el puerto 9999 de tu local.
docker run --name lemoncoders-web -d -p 9999:80 nginx 
docker cp lemoncoders-web/. lemoncoders-web:/usr/share/nginx/html/
docker exec lemoncoders-web ls /usr/share/nginx/html/

# 3. Eliminar todos los contenedores que tienes ejecutándose en tu máquina en una sola línea. 
docker rm -f $(docker ps -aq)