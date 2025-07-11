# Día I: Introducción a Docker 🐳

![Docker](imagenes/Contenedores%20I%20-%20Hello%20World%20-%20Lemoncode.jpeg)

## 🧰 Cómo instalar Docker en tu máquina local

A día de hoy, la forma más sencilla de instalar Docker en tu máquina local es a través de **Docker Desktop**, el cual está disponible tanto para Windows, como para Linux y Mac. Descarga el instalable que necesites para tu sistema operativo [desde la página oficial](https://www.docker.com/). Una vez instalado, ¡ya estamos listos para empezar a jugar! ✨

## 👀 Conociendo Docker desde Docker Desktop

Cuando hayas instalado Docker Desktop verás que puedes empezar de forma muy visual, aunque es posible que al principio no tengas muy claro qué es lo que tienes que hacer 😅. Aunque es recomendable dominar la línea de comandos, ya que es la forma más rápida y común de trabajar con Docker en la vida real, vamos a empezar por lo sencillo para luego ir avanzando cada vez un poco más y que te vayas sintiendo cómod@ con los diferentes conceptos.

### 🚀 Misión 1: Mi primer contenedor con un servidor web

Ok, como estamos en el módulo de contenedores, y ya tenemos instalado todo lo que necesitamos para empezar, nuestra primera misión va a ser, lógicamente, pues crear nuestro primer contenedor, como no podía ser de otra manera 😅 Y para este primer ejemplo vamos a crear un contenedor que dentro tenga un servidor web, en este caso usando Nginx, aunque podría ser cualquier otro, como también veremos.

Ahora mismo en nuestra instalación de Docker Desktop no tenemos absolutamente nada, así que vamos a ver paso a paso cómo podemos crear este contenedor desde aquí.

Lo primero que necesitas es saber la imagen que podemos utilizar para tener un contenedor con Nginx ¿Y cómo puedo saber esto? Pues para ello tenemos que ir la sección llamada **Docker Hub** dentro de Docker Desktop:

![Docker Hub en Docker Desktop](imagenes/Docker%20Hub%20en%20Docker%20Desktop.png)

Aquí vas a poder ver que tenemos un buscador donde podemos investigar qué imágenes hay disponibles, listas para usar. Por lo que si busco por `nginx` seré capaz de encontrar lo que busco.

![nginx Docker Hub en Docker Desktop](imagenes/Nginx_en%20Docker%20Hub.png)

Si hago clic sobre la misma...

![Información sobre la imagen de Nginx](imagenes/Información%20sobre%20la%20imagen%20de%20nginx.png)

Podrás ver información relacionada con la imagen, como por ejemplo las etiquetas disponibles, la descripción de la misma, etc. Ya entraremos más en detalle en todo esto, pero por ahora lo que nos interesa es ejecutar un contenedor que utilice la misma, así que vamos a ejecutar el botón **Run** que aparece en la parte superior derecha de la pantalla.

Al hacerlo ocurriran dos cosas:

1. En la parte inferior dice que está haciendo pull de la imagen, es decir, descargándola a tu máquina local.
2. Te aparecerá un dialogo donde te pide un par de valores y la opción de ejecutar el contenedor.

![Ejecutar contenedor de Nginx](imagenes/Ejecutar%20un%20nuevo%20contenedor%20desde%20Docker%20Desktop.png)

Como por ahora no tenemos mucha idea, vamos a hacer clic directamente sobre el botón **Run** y veremos qué ocurre. Si todo ha ido bien, deberías ver en la sección de **Containers** que ya tienes un contenedor en ejecución 🚀, y si haces clic sobre él podrás ver más información relacionada con el mismo 🎉


>[!IMPORTANT]
>Es muy importante que tengas en cuenta que una imagen no es un contenedor. Es decir, que yo podría repetir este proceso varias veces y crear varios contenedores a partir de la misma imagen, cada uno con su propia configuración, estado, etc. Por ejemplo, si vuelves a hacer clic en el botón **Run** verás que te aparece un nuevo diálogo donde puedes configurar el nombre del contenedor, los puertos que quieres mapear, etc. Podríamos decir que una imagen es como una plantilla, y un contenedor es una instancia de esa plantilla.


Vale, ya tengo uno o varios contenedores con nginx, pero si ahora accedo a http://localhost no tengo ningun servidor web funcionando, ¿por qué? pues porque estos contenedores viven en un entorno aislado, y para poder acceder a ellos desde mi máquina local tengo que mapear los puertos del contenedor a los de mi máquina. Esto lo veremos más adelante, pero por ahora vamos a ver cómo podemos hacer esto desde la interfaz gráfica de Docker Desktop.

Si ahora vuelvo a crear un nuevo contenedor y hago clic en el botón **Run** de nuevo, verás que en el diálogo que aparece un cuadro de texto donde puedo proporcionar un puerto.

![Crear un contenedor indicando un puerto de mapeo](imagenes/Crear%20un%20contenedor%20indicando%20un%20puerto%20de%20mapeo.png)

A lo que se refiere es a un puerto de mi máquina local que esté libre por el cual yo quiera/pueda acceder a este nuevo contenedor que voy a crear. En mi ejemplo he usado el puerto 8080 pero podría ser cualquier otro por encima de 1024, ya que los puertos por debajo de este número suelen estar reservados para servicios del sistema operativo.


Para esta primera clase, te recomiendo ejecutar todos los comandos directamente en el Terminal integrado en Docker Desktop, así podrás ver el resultado en la interfaz gráfica al instante.

![Terminal integrado en Docker Desktop](imagenes/Terminal%20integrado%20en%20Docker%20Desktop.png)

## Visual Studio Code y Docker

Ahora que tienes Docker Desktop instalado, puedes integrarlo con Visual Studio Code para una experiencia aún más fluida. Asegúrate de tener instalada [la extensión Container Tools](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-containers). Esto te permitirá gestionar contenedores, imágenes y redes directamente desde el editor. Además, como tienes instalado Docker CLI, podrás ejecutar comandos de Docker desde el terminal integrado de VS Code.

A partir de este momento, usaremos este editor para todas nuestras prácticas, ya que es gratuito, multiplataforma y muy popular entre los desarrolladores. Si no lo tienes instalado, descárgalo desde [su página oficial](https://code.visualstudio.com/).

## 🏁 Ejecuta tu primer contenedor

```bash
docker run hello-world
```

`hello-world` es la imagen que usas para crear tu contenedor. Una imagen es como una clase: contiene un SO, una aplicación y sus dependencias. Si lo lanzas desde el terminal integrado, verás que aparece un nuevo contenedor que se pone en verde y rápidamente pasa a gris. Esto es porque el contenedor `hello-world` se ejecuta una vez y se para.

Para ver las imágenes descargadas en tu local:

```bash
docker image ls
```

O bien:

```bash
docker images
```

## 🏗️ ¿Y estas imágenes de dónde vienen?

Todas las imágenes por defecto de Docker vienen de [Docker Hub](https://hub.docker.com/), un repositorio de imágenes que puedes usar en tus proyectos. Puedes buscar imágenes en Docker Hub desde la interfaz gráfica de Docker Desktop o desde el CLI. Por ejemplo, para buscar un servidor web como Nginx:

```bash
docker search nginx
```

Y para ejecutarlo:

```bash
docker run nginx
```

A diferencia de `hello-world`, este contenedor sigue ejecutándose y el terminal queda "esperando" a que termines. Esto es porque Nginx es un servidor web y necesita estar activo para que puedas acceder a él. Pero... ¿cómo accedemos? ¡Vamos a verlo! 👇

## 🌐 Mapear puerto de contenedor a los puertos de mi máquina local

Para acceder a un contenedor desde tu máquina local necesitas mapear el puerto del contenedor al de tu máquina. Por ejemplo, para acceder a Nginx mapea el puerto 80 del contenedor al 8080 de tu máquina:

```bash
docker run --publish 8080:80 nginx
```

O bien:

```bash
docker run -p 8080:80 nginx
```

Ahora si accedes a [http://localhost:8080](http://localhost:8080) verás el servidor web de Nginx. 🌍

## 🕹️ ¿Y si quiero ejecutar un contenedor en segundo plano?

Puedes ejecutar un contenedor en segundo plano usando la opción `-d` o `--detach`:

```bash
docker run --detach -p 8080:80 nginx
```

O bien:

```bash
docker run -d -p 8080:80 nginx
```

## 📋 Listar todos los contenedores que tengo en ejecución

Para ver los contenedores en ejecución:

```bash
docker ps
```

Para ver todos los contenedores (incluidos los parados):

```bash
docker ps --all
```

O bien:

```bash
docker ps -a
```

## 🏷️ Bautizar contenedores

Docker asigna nombres aleatorios a los contenedores, pero puedes elegir el nombre que quieras con la opción `--name`:

```bash
docker run -d --name web -p 9090:80 nginx
```

Para ver el nuevo contenedor llamado `web`:

```bash
docker ps
```

También puedes renombrar contenedores existentes:

```bash
docker rename NOMBRE_ASIGNADO_POR_DOCKER hello-world
docker ps -a
```

## 🖥️ Ejecutar un contenedor y lanzar un shell interactivo en él

Para lanzar un shell interactivo en un contenedor:

```bash
docker run --interactive --tty ubuntu /bin/bash
```

O bien:

```bash
docker run -it ubuntu /bin/bash
```

Comprueba la versión del SO dentro del contenedor:

```bash
cat /etc/os-release
exit
```

## 🔄 ¿Cómo ejecutar comandos en un contenedor ya en ejecución?

Puedes conectarte a un contenedor en ejecución desde Docker Desktop o desde el CLI. Por ejemplo:

```bash
docker run --name webserver -d nginx 
```

Y luego:

```bash
docker exec -it webserver bash # Ejecuto bash dentro del contenedor y con -it me atacho a él
cat /etc/nginx/nginx.conf 
exit
```

## 🛠️ Ejecutar comandos desde mi local dentro del contenedor

Puedes usar el subcomando `exec` para ejecutar comandos dentro del contenedor. Por ejemplo, para ver los logs de Nginx:

```bash
docker exec web ls /var/log/nginx
```

## 🛑 ¿Cómo paro un contenedor?

Para parar un contenedor:

```bash
docker stop web
```

Para volver a arrancarlo:

```bash
docker start my-web
```

## 🗑️ ¿Y si quiero eliminarlo del todo de mi ordenador?

Asegúrate de que el contenedor está parado:

```bash
docker stop my-web
```

Y elimínalo:

```bash
docker rm my-web
```

Comprueba que ya no aparece:

```bash
docker ps -a
```

También puedes hacerlo desde la interfaz gráfica de Docker Desktop.

### ⚡ Comandos combinados para limpiar rápido

Para parar y eliminar todos los contenedores:

```bash
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
```

## 🗄️ SQL Server dockerizado

Vamos a ver cómo usar Docker para tener un SQL Server en tu máquina local. Por ejemplo, para desarrollo, puedes usar la imagen oficial de Microsoft:

```bash
docker run --name mysqlserver \
-p 1433:1433 \
-e 'ACCEPT_EULA=Y' \
-e 'SA_PASSWORD=Lem0nCode!' \
-d mcr.microsoft.com/mssql/server:2019-latest
```

- `docker run`: lanza un contenedor.
- `--name mysqlserver`: nombre del contenedor.
- `-p 1433:1433`: mapea el puerto.
- `-e 'ACCEPT_EULA=Y'`: acepta la licencia.
- `-e 'SA_PASSWORD=Lem0nCode!'`: contraseña del usuario `sa`.
- `-d mcr.microsoft.com/mssql/server:2019-latest`: imagen a usar.

Conéctate al contenedor:

```bash
docker exec -it mysqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P Lem0nCode! 
```

Crea una base de datos y una tabla:

```sql
CREATE DATABASE Lemoncode;
GO
USE Lemoncode;
GO
CREATE TABLE Courses(ID int, Name varchar(max), Fecha DATE);
GO
SET LANGUAGE ENGLISH;
GO
INSERT INTO Courses VALUES (1, 'Bootcamp DevOps', '2024-10-8'), (2,'Máster Frontend','2024-10-08');
GO
```

Conéctate con Visual Studio Code, [con la extensión MSSQL](https://marketplace.visualstudio.com/items?itemName=ms-mssql.mssql), a tu `localhost:1433` y tendrás acceso a tu SQL Server dockerizado! 🗃️

Cuando termines, para y elimina tu SQL Server dockerizado:

```bash
exit
docker stop mysqlserver && docker rm mysqlserver
```

O bien, todo de golpe:

```bash
docker rm -f mysqlserver
```

---

## 🎉 ¡Felicidades!

En esta primera clase has aprendido a:

- 🖥️ Instalar Docker Desktop en tu máquina local.
- 👀 Conocer Docker desde Docker Desktop.
- 🏁 Ejecutar tu primer contenedor.
- 📦 Ver las imágenes descargadas en tu local.
- 🔍 Buscar imágenes en Docker Hub.
- 🌐 Mapear puertos de contenedor a tu máquina local.
- 🕹️ Ejecutar un contenedor en segundo plano.
- 📋 Listar todos los contenedores en ejecución.
- 🏷️ Bautizar contenedores.
- 🖥️ Ejecutar un contenedor y lanzar un shell interactivo en él.
- 🔄 Ejecutar comandos en un contenedor ya en ejecución.
- 🛠️ Ejecutar comandos desde tu local dentro del contenedor.
- 🛑 Parar un contenedor.
- 🗑️ Eliminar un contenedor.
- 🗄️ SQL Server dockerizado.

En la siguiente clase veremos cómo crear nuestras propias imágenes de Docker.

Happy coding {🍋}
