#Esta es la imagen que utilizaré como base de mi imagen
FROM node:10.13-alpine 

#Establezco la ruta /app como directorio de trabajo para alojar mi aplicación, instalar dependencias, etc.
WORKDIR /app

#Copio los archivos package.json y package-lock.json en el raiz de mi directorio /app
COPY ["package.json", "package-lock.json", "./"]

#Instalo las dependencias de Node.js definidas en el archivo package.json
RUN npm install

#Copio el resto de archivos en el directorio
COPY . /app

#Añado como metadato que el puerto que utiliza mi aplicación para comunicarse es el 3000. Se puede verificar en la linea 8 del archivo server.js
EXPOSE 3000

#Indica el comando que se va a ejecutar cuando un contenedor se arranque a partir de esta imagen
CMD [ "node", "server.js" ]