# Día I: Introducción a Docker

![Docker](imagenes/Contenedores%20I%20-%20Hello%20World.jpeg)

## Cómo instalar Docker en tu máquina local

A día de hoy, la forma más sencilla de instalar Docker en tu máquina local es a través de Docker Desktop, el cual está disponible
tanto para Windows, como para Linux y Mac. Para descargar el instalable que necesites para tu sistema operativo [desde la página oficial](https://www.docker.com/). Una vez que lo hayas instalado ya estamos listos para empezar a jugar ✨.

## Conociendo Docker desde Docker Desktop

En el momento que hayas instalado Docker Desktop te darás cuenta de que puedes empezar con el mismo de una forma muy visual. Pero es recomendable que sepas dominar la línea de comandos ya que no solo es la forma más rápida de trabajar con Docker sino que también es la forma más común de trabajar con Docker en la vida real. En primer lugar porque puedes versionar tus comandos, automatizarlos, compartirlos, etcétera y también porque habrá ocasiones en las que no tengas acceso a la interfaz gráfica de Docker Desktop.

Para esta primera clase te recomiendo que todos los comndos que aprendas los ejecutes directamente en el Terminal que ahora viene integrado como parte de Docker Desktop ya que te permite ver el resultado en la interfaz gráfica en el momento que ejecutas un comando.

![Terminal integrado en Docker Desktop](imagenes/Terminal%20integrado%20en%20Docker%20Desktop.png)

## Ejecuta tu primer contenedor

Ahora lo que vamos a hacer es ejecutar nuestro primer contenedor. Para ello, quedate en el apartado de contenedores y vamos a ejecutar el siguiente comando en el terminal:

```bash
docker run hello-world
```

`hello-world` es la imagen que estás usando para crear tu contenedor. Una imagen es un objeto que contiene un SO, una aplicación y las dependencias que esta necesita. Si eres desarrollador puedes pensar en una imagen como si fuera una clase. Si lo has lanzado a través del terminal integrado te habrás dado cuenta un nuevo contenedor ha aparecido se ha puesto en verde y rápidamente ha pasado a gris. Esto es así porque el contenedor hello-world es un contenedor que se ejecuta una vez y se para. 

Como parte del proceso de creación de un contenedor, Docker descarga la imagen que le has indicado que necesita. Si quieres ver las imágenes que tienes descargadas en tu local puedes ejecutar el siguiente comando:

```bash
docker image ls
```

O bien

```bash
docker images
```

## ¿Y estas imágenes de dónde vienen? 

Pues todas las que utiliza por defecto Docker vienen de un lugar llamado [Docker Hub](https://hub.docker.com/). Docker Hub es un repositorio de imágenes de Docker que puedes utilizar para tus propios proyectos. Puedes buscar imágenes en Docker Hub a través de la interfaz gráfica de Docker Desktop o bien a través del CLI. Por ejemplo, imaginate que ahora quiero buscar un servidor web, como Nginx. A través de la interfaz podría utilizar `Control + K`o `Command + K` y buscar `nginx` o bien a través del CLI podría ejecutar el siguiente comando:

```bash
docker search nginx
```

Y ahora para ejecutarlo podríamos hacerlo de la misma forma que lo hicimos para el que utilizó la imagen `hello-world`:

```bash
docker run nginx
```

En este caso, como puedes ver ocurren un par de cosas diferentes a las que vimos con el contenedor anterior: en primer lugar que este después de descargar la imagen se sigue ejecutando y en segundo lugar el terminal se queda "esperando" a que termines de ejecutar el contenedor. Esto es porque Nginx es un servidor web y si no se quedara "esperando" a que termines de ejecutar el contenedor, el servidor web se pararía y no podrías acceder a él. Sin embargo... ¿cómo puedo acceder a él? Pues vamos a verlo.

## Mapear puerto de contenedor a los puertos de mi máquina local

Para poder acceder a un contenedor desde nuestra máquina local necesitamos mapear el puerto del contenedor al puerto de nuestra máquina local. Por ejemplo, si queremos acceder a nuestro servidor web de Nginx necesitamos mapear el puerto 80 del contenedor al puerto 8080 de nuestra máquina local. Para ello, podemos hacerlo a través de la interfaz gráfica de Docker Desktop o bien a través del CLI. Si lo hacemos a través de la interfaz gráfica, cuando ejecutemos el contenedor nos aparecerá una ventana emergente en la que podremos indicar el puerto al que queremos mapear el puerto del contenedor. Si lo hacemos a través del CLI, podemos hacerlo de la siguiente forma:

```bash
docker run --publish 8080:80 nginx
```

O bien

```bash
docker run -p 8080:80 nginx
```

Ahora si accedes a [http://localhost:8080](http://localhost:8080) podrás ver el servidor web de Nginx.

## ¿Y si quiero ejecutar un contenedor en segundo plano?

Si bien es cierto que cuando ejecutas un contenedor por primer vez el ver sus logs directamente puede ser bastante útil, lo cierto es que cuando tienes que ejecutar varios contenedores es poco práctico. Es por ello que podemos pedirle que se ejecute en segundo plano a través de la opción `-d` o `--detach`.

```bash
docker run --detach -p 8080:80 nginx
```

O bien

```bash
docker run -d -p 8080:80 nginx
```

## Listar todos los contenedores que tengo en ejecución

Ahora que ya hemos lanzado varios contenedores te preguntarás ¿cómo puedo ver los que tengo ahora mismo ejecutándose? Pues bien, para ello puedes ejecutar el siguiente comando:

```bash
docker ps
```

Pero... yo he lanzado muchos más ¿dónde están? Pues bien, para ver todos los contenedores que tengo en ejecución puedes ejecutar el siguiente comando:

```bash
docker ps --all
```

O bien

```bash
docker ps -a
```

## Bautizar contenedores

En todos los ejemplos anteriores, Docker ha elegido un nombre aleatorio para nuestros contenedores (columna NAMES). Sin embargo, muchas veces es útil poder elegir nosotros el nombre que queramos. Para elegir el nombre de tu contenedor basta con utilizar la opción `--name`.

```bash
docker run -d --name web -p 9090:80 nginx
```

Y si vuelves a listar los contenedores verás que tienes uno nuevo llamado web:

```bash
docker ps
```

También puedes renombrar existentes

```bash
docker rename NOMBRE_ASIGNADO_POR_DOCKER hello-world
docker ps -a
```

## Ejecutar un contenedor y lanzar un shell interactivo en él

Otra tarea común que solemos hacer con Docker es lanzar un shell interactivo en un contenedor. Para ello podemos utilizar el siguiente comando:

```bash
docker run --interactive --tty ubuntu /bin/bash
```

O bien

```bash
docker run -it ubuntu /bin/bash
```

Para comprobar que efectivamente estamos dentro del mismo, vamos a revisar la versión del SO que está instalado en tu contenedor:

```bash
cat /etc/os-release
exit
```

## Vale ¿y cómo puedo ejecutar comandos en un contenedor que ya está en ejecución?

En este caso tenemos dos opciones: podemos ir directamente al contenedor al que queramos conectarnos en Docker Desktop o bien a través del CLI.

Por ejemplo, creamos un contenedor:

```bash
docker run --name webserver -d nginx 
```

Y ahora nos conectamos a él a través del CLI:

```bash
docker exec -it webserver bash #Ejecuto el proceso bash dentro del contenedor y con -it me atacho a él
cat /etc/nginx/nginx.conf 
exit
```

## ¿Y si quiero ejecutar comandos desde mi local dentro del contenedor?

Pues también es posible. Para ello podemos usar el subcomando `exec` de Docker. Por ejemplo, imagínate que quieres ver los logs de tu servidor web:

```bash
docker exec web ls /var/log/nginx
```

## ¿Cómo paro un contenedor?

Pues ya estamos llegando al final de las demos de hoy. Ahora lo que vamos a hacer es limpiar. Y para ello lo primero que debemos aprender es a parar los contenedores que tenemos en marcha.

```bash
docker stop web
```

Si quisiera volver a arrancarlo podría hacerlo a través del siguiente comando:

```bash
docker start my-web
```

## ¿Y si quiero eliminarlo del todo de mi ordenador?

En ese caso debemos asegurar que el contenedor está parado:

```bash
docker stop my-web
```

Y ahora lo que vamos a hacer es eliminarlo:

```bash
docker rm my-web
```

Si ahora comprobamos los contenedores que tenemos en ejecución veremos que ya no aparece:

```bash
docker ps -a
```

Por supuesto, estas acciones podemos hacerlas de forma sencilla utilizando la interfaz gráfica de Docker Desktop. 

Otra forma también muy rápida de hacer todo esto es utilizando lo que yo llamo *comandos combinados*. Por ejemplo, imagínate que quieres parar y eliminar todos los contenedores que tienes en ejecución:

Podrías recuperar el ID de todos ellos utilizando este comando:

```bash
docker ps -aq
```

Y pasarle todos los IDs a los comandos `stop`:

```bash
docker stop $(docker ps -aq)
```

y `rm`:

```bash
docker rm $(docker ps -aq)
```

## SQL Server dockerizado

Para finalizar, vamos a ver un ejemplo de cómo podemos utilizar Docker para tener un SQL Server en nuestra máquina local. Imagínate que estás desarrollando una aplicación que necesita de un SQL Server y no quieres tener que montarte uno y ensuciar tu máquina, o tener que crearte una máquina virtual, configurarla, bla, bla, bla. Pues bien, para ello puedes utilizar Docker. Y ahora que ya sabes cómo hacerlo vamosa terminar utilizando otra imagen de Docker Hub. En este caso vamos a utilizar la imagen de SQL Server de Microsoft. Para ello, vamos a ejecutar el siguiente comando:

```bash
docker run --name mysqlserver \
-p 1433:1433 \
-e 'ACCEPT_EULA=Y' \
-e 'SA_PASSWORD=Lem0nCode!' \
-d mcr.microsoft.com/mssql/server:2019-latest
```

Este comando es un poco más complejo que los anteriores, así que vamos a verlo por partes:

- `docker run`: es el comando que utilizamos para lanzar un contenedor.
- `--name mysqlserver`: es el nombre que le vamos a dar al contenedor.
- `-p 1433:1433`: es el puerto al que vamos a mapear el puerto del contenedor.
- `-e 'ACCEPT_EULA=Y'`: es una variable de entorno que necesitamos para aceptar la licencia de SQL Server.
- `-e 'SA_PASSWORD=Lem0nCode!'`: es una variable de entorno que necesitamos para indicar la contraseña del usuario `sa`.
- `-d mcr.microsoft.com/mssql/server:2019-latest`: es la imagen que vamos a utilizar para crear el contenedor.

Una vez que hayas ejecutado el comando, si vuelves a la interfaz gráfica de Docker Desktop verás que tienes un nuevo contenedor en ejecución. Ahora lo que vamos a hacer es conectarnos a él a través del CLI:

```bash
docker exec -it mysqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P Lem0nCode! 
```

Y ahora lo que vamos a hacer es crear una base de datos, una tabla y unos registros:

```sql
CREATE DATABASE Lemoncode;
GO
```

Selecciona la base de datos:

```sql
USE Lemoncode;
GO
```

Crea una tabla:

```sql
CREATE TABLE Courses(ID int, Name varchar(max), Fecha DATE);
GO
```

Inserta registros en la tabla:

```sql
SET LANGUAGE ENGLISH;
GO
INSERT INTO Courses VALUES (1, 'Bootcamp DevOps', '2024-10-8'), (2,'Máster Frontend','2024-10-08');
GO
```

Y ahora conectate con Azure Data Studio a tu localhost:1433 y tendrás tu acceso a tu SQL Server dockerizado!

Una vez que termines, ya puedes parar y eliminar tu SQL Server dockerizado

```bash
exit
```

```bash
docker stop mysqlserver && docker rm mysqlserver
```

Y también puedes pararlo y eliminarlo de golpe

```bash
docker rm -f mysqlserver
```

¡Felicidades 🎉! En esta primera clase has aprendido a:

- Instalar Docker Desktop en tu máquina local.
- Conocer Docker desde Docker Desktop.
- Ejecutar tu primer contenedor.
- Ver las imágenes que tienes descargadas en tu local.
- Buscar imágenes en Docker Hub.
- Mapear puerto de contenedor a los puertos de tu máquina local.
- Ejecutar un contenedor en segundo plano.
- Listar todos los contenedores que tienes en ejecución.
- Bautizar contenedores.
- Ejecutar un contenedor y lanzar un shell interactivo en él.
- Ejecutar comandos en un contenedor que ya está en ejecución.
- Ejecutar comandos desde tu local dentro del contenedor.
- Parar un contenedor.
- Eliminar un contenedor.
- SQL Server dockerizado.

En la siguiente clase veremos cómo podemos crear nuestras propias imágenes de Docker.

Happy coding {🍋}
