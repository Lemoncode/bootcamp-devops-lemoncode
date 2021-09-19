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
#O bien seleccionando el archivo Dockerfile con el botón derecho y hacer clic en Build Image...

# 2. Ejecutar un contenedor con tu nueva imagen usando Visual Studio Code


