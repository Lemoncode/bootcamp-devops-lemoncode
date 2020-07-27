#Mi primera applicación a contenerizar > Node.js
cd 01-contenedores/contenedores-iii/hello-world

#Ejecutar la app sin contenerizar
npm install
node server.js

#Revisar el archivo Dockerfile
cat Dockerfile

#Revisar el archivo .dockerignore
cat .dockerignore

#Generar la imagen en base al Dockerfile
docker build --tag=hello-world . 

#Ver el historico generado para la imagen
docker history hello-world #Los que tienen valor 0B son metadatos

#Ejecutar un nuevo contenedor usando tu nueva imagen:
docker run -p 4000:3000 hello-world

#Añadir una nueva etiqueta a tu nueva imagen
docker image tag hello-world 0gis0/hello-world:latest
docker images #El image ID es el mismo para ambas etiquetas porque apuntan a la misma imagen

#Publicar tu nueva imagen en Docker Hub
docker push 0gis0/hello-world:latest

#Elimina la imagen de local
docker rm 09c212370c89 34690fc1adf8 --force
docker rmi hello-world 0gis0/hello-world

#Ejecutar un nuevo contenedor usando mi nueva imagen en Docker Hub
docker run -p 4000:3000 0gis0/hello-world


#### Ejemplo de contenerización de una aplicación en .NET #####



### Ejemplo de aplicación en Java ####




##### Buenas prácticas en la construcción de imágenes #########



### Multi-stage Builds ###


### Squash de una imagen ###