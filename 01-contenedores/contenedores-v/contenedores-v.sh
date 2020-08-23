# Parte 5: Volúmenes #

#Listar los volumenes en el host
docker volume ls

#Crear un nuevo volumen
docker volume create data

#Inspeccionar el volumen
docker volume inspect data

#Eliminar un volumen específico 
docker volume rm data

#Eliminar todos los volumenes que no esté atachados a un contenedor
docker volume prune -f

#Crear un contenedor que a su vez crea un volumen
docker container run -dit --name my-container \
    --mount source=my-data,target=/vol \
    alpine

#Puedes comprobar que el volumen se ha creado correctamente
docker volume ls

#No puedes eliminar un volumen si hay un contenedor que lo tiene atachado. Te dirá que está en uso.
docker volume rm my-data

#Ahora vamos a añadir algunos datos a nuestro volumen
docker container exec -it my-container sh
echo "Hola Lemoncoders!" > /vol/file1
ls -l /vol
cat /vol/file1
exit

#Ahora voy a eliminar el contenedor
docker rm my-container -f

#Pero el volumen todavía existe
docker volume ls

#Por lo que puedo crear un nuevo contenedor y volver a atachar el volumen que tenía con mis datos
docker container run -dit --name another-container \
    --mount source=my-data,target=/vol \
    alpine

#Comprueba que tu archivo file1 sigue ahí
docker container exec -it another-container sh
ls -l /vol
cat /vol/file1
exit

# Backups
docker run -v /dbdata --name dbstore ubuntu /bin/bash
docker run --rm --volumes-from dbstore -v $(pwd):/backup ubuntu tar cvf /backup/backup.tar /dbdata

## Bind mounts ##

#Se utiliza cuando quieres montar un archivo o directorio dentro de un contenedor
cd 01-contenedores/contenedores-v
#dev-folder es el directorio que voy a montar dentro de mi contenedor
docker run -dit --name devtest --mount type=bind,source="$(pwd)"/dev-folder,target=/usr/share/nginx/html/ -p 8080:80 nginx
docker inspect devtest
#Ahora cambia en el host el contenido de la carpeta dev-folder

#Usar el bind mount como read-only
docker rm -f devtest
docker run -dit --name devtest --mount type=bind,source="$(pwd)"/dev-folder,target=/usr/share/nginx/html/,readonly -p 8080:80 nginx
docker inspect devtest

#Como está en modo lectura, en teoría no podría crear ningún archivo dentro del directorio donde está montada mi carpeta local
docker container exec -it devtest sh
ls /usr/share/nginx/html
touch /usr/share/nginx/html/index2.html #Dará error porque el montaje está en modo read-only
exit


#Deberes:
# 1.
# 2. 
# 3.