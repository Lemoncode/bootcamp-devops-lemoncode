#Demo 0: ver información del cliente y el servidor que forman Docker Engine.
docker version 

#Por defecto se asume que se utilizarán contenedores Linux ( OS/Arch:  linux/amd64 en el apartado de Server).

#Si estás en Windows puedes cambiar al tipo de contenedores Windows haciendo click con el botón derecho sobre el icono de Docker en la barra de tareas y eligiendo Switch to Windows Containers
cd c:\Program Files\Docker\Docker> .\dockercli -SwitchDaemon 

docker info

#### Demo 1: Ejecuta tu primer contenedor ####

#Ejecuta tu primer contenedor
#CLI  command  image name
docker run hello-world

#hello-world es la imagen que estás usando para crear tu contenedor. Una imagen es un objeto que contiene un SO, una aplicación y las dependencias que esta necesita. Si eres desarrollador puedes pensar en una imagen como si fuera una clase.

#Lista las imágenes que tienes descargadas en tu local
docker image ls

#¿Y estas imágenes de dónde vienen? 
#De Docker Hub :-) https://hub.docker.com/
#O bien a través del CLI
docker search nginx

#### Demo 2: exponer puertos en localhost (Nginx) ####
docker run --name my-nginx -p 8080:80 nginx #Puedes ver cuando se ejecuta este comando que el terminal te muestra los logs que van surgiendo de este contenedor que acabas de crear.

#### Ver qué puertos tiene un contenedor expuestos ####
docker port my-nginx

#### Demo 3: Gestionar contenedores en tu máquina ####

#Lista los contenedores ejecutándose en tu máquina
docker ps #¿Y los otros contenedores que he ejecutado?

docker ps --all #con --all puedo ver todos los contenedores, incluso los que ya terminaron de ejecutarse, como hello-world

# ¿Cómo paro un contenedor?
docker stop my-nginx

# ¿Y si quiero volver a iniciarlo?
docker start my-nginx

#Es importante hacer uso de nombres personalizados porque será más sencillo luego referirnos a él como veremos después.
docker rename nifty_snyder hello-world

#¿Y si quiero eliminarlo del todo de mi ordenador?
docker rm hello-world


#Todo esto también es posible verlo desde la interfaz de Docker Desktop (A través de la opción Dashboard)

#### Demo 4: Attach ###
#Si quiero atacharme a un contenedor
docker run --name webserver -d nginx  #Con -d desatacho
docker exec -it webserver bash #Ejecuto el proceso bash dentro del contenedor y con -it me atacho a él
cat /etc/nginx/nginx.conf 


#### Demo 5: Copiar un archivo desde mi local a dentro del contenedor ####
#https://docs.docker.com/engine/reference/commandline/cp/
docker cp local.html my-nginx:/usr/share/nginx/html/local.html

#### Demo 6: Copiar el archivo de logs en local ####
docker cp my-nginx:/var/log/nginx/access.log access.log

#### Demo 7: Copiar múltiples archivos dentro de una carpeta ####
mkdir nginx-logs
docker cp my-nginx:/var/log/nginx/. nginx-logs


#### Demo 8: Ejecutar comandos desde mi local dentro del contenedor ####
docker exec my-nginx ls /var/log/nginx


#### Demo 9: lo mismo con SQL Server ####
# Imagínate que estás desarrollando una aplicación que necesita de un SQL Server y no quieres tener que montarte uno y ensuciar tu máquina, o tener que crearte una máquina virtual, configurarla, bla, bla, bla
# https://hub.docker.com/_/microsoft-mssql-server
docker run --name mysqlserver -p 1433:1433 \
-e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=Lem0nCode!' \
-d mcr.microsoft.com/mssql/server:2019-latest #-d significa detach, lo cual permite que el terminal no se quede enganchado como en el caso anterior.

#También puedes utilizar sqlcmd para conectarte con tu instancia
docker exec -it mysqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P Lem0nCode! #### -it No quiero que el terminal se quede "esperando" al contenedor ####

#Crea una base de datos
CREATE DATABASE Lemoncode;
GO

#Selecciona la base de datos
USE Lemoncode;
GO

#Crea una tabla
CREATE TABLE Courses(ID int, Name varchar(max), Fecha DATE);
GO

#Insertar registros en la tabla
SET LANGUAGE ENGLISH;
GO
INSERT INTO Courses VALUES (1, 'Bootcamp DevOps', '2020-10-5'), (2,'Máster Frontend','2020-09-25');
GO

#Ahora conectate con Azure Data Studio a tu localhost:1433 y tendrás tu acceso a tu SQL Server dockerizado!

#Una vez que termines, ya puedes parar y eliminar tu SQL Server dockerizado
docker stop mysqlserver && docker rm mysqlserver


#### Bonus track: Eliminar todos los contenedores e imágenes de local ####

#Listar todos los IDs de todos los contenedores
docker ps --help
docker ps -aq

#Parar todos los contenedores 
docker stop $(docker ps -aq)
docker ps

#Eliminar todos los contenedores
docker rm $(docker ps -aq)