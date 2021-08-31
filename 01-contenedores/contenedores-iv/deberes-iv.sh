#Deberes:
#1. Crea un contenedor que cree un volumen llamado images y que utilice la imagen 0gis0/galleryapp
#1.1 El volume debe estar montado en la carpeta images del WORKDIR del contenedor 
docker run  -p 9000:8080 --mount source=images,target=/usr/src/app/images galleryapp

#Puedes copiar las imagenes con este comando
docker cp /Users/gis/Pics/. zen_perlman:/usr/src/app/images

# 2. Elimina el contenedor anterior y comprueba que tu volumen sigue estando disponible.
docker rm -f CONTAINER_NAME
#Puedes ver que el volumen sigue estando disponible con este comando
docker volume ls
# O a través del apartado Docker de Visual Studio Code
#Puedes ver el contenido del volumen creando otro contenedor o usando la opción *Explore in Development Container*
# 3. Mapea una carpeta local a un contenedor. Cambia el contenido de dicha carpeta y comprueba que ves los cambios dentro del contenedor.
docker run  -p 9000:8080 --mount type=bind,source=/Users/gis/Pics,target=/usr/src/app/images galleryapp