#Deberes: 
cd contenedores-iii
# 1. Dockeriza la aplicación de la carpeta hello-lemoncoder con Visual Studio Code

#Antes de dockerizar la aplicación es recomendable comprobar antes si esta funciona, por no volvernos locos.
cd hello-lemoncoder
npm install
npm start

#Una vez comprobado, utiliza Comand + P (Mac) o Control + P (Windows) y busca lo siguiente:
# > Add Docker Files to Workspace > Node.js > selecciona el package.json de la lista y el puerto es el 3000
# Esto debería de generar el archivo Dockerfile dentro de hello-lemoncoder
# Para generar la imagen podemos hacerlo con este comando:
docker build . -t hellolemoncoder --no-cache
#O bien seleccionando el archivo Dockerfile con el botón derecho y hacer clic en Build Image...

# 2. Ejecutar un contenedor con tu nueva imagen
docker run --name hello -p 3000:3000 hellolemoncoder

# 3. Añade un archivo de prueba en el contenedor y crea una nueva imagen a partir de dicho contenedor.
#Creo un archivo en local
echo "Hello, World!" > hello-lemoncoder.txt
#Lo copio dentro del contenedor. En mi ejemplo en la ruta donde está el código fuente de mi app
docker cp hello-lemoncoder.txt hello:/usr/src/app/hello-lemoncoder.txt
#Compruebo que se ha copiado correctamente
docker exec hello ls -l /usr/src/app/
#Hago un commit con el cambio
docker commit hello newhelloimage
#Compruebo que tengo una nueva imagen
docker images
#Genero un nuevo contenedor con la nueva imagen
docker run -d --name newhello -P newhelloimage
#Compruebo que mi nuevo archivo está donde lo copie
docker exec newhello ls -l /usr/src/app/