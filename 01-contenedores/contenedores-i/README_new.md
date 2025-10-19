# Día I: Introducción a Docker 🐳 ✅

![Docker](imagenes/Contenedores%20I%20-%20Hello%20World%20-%20Lemoncode.jpeg)

¡Hola lemoncoders! 👋 Con este módulo arrancamos con los contenedores. Pero antes de nada es importante que eches un vistazo a los vídeos de introducción que hemos dejado preparados para ti en el Campus de Lemoncode.

## 🎬 Vídeos de la introducción en el campus

Se asume que has visto los siguientes vídeos para comenzar con este módulo:

| # | Tema |
|---|------|
| 1 | 📘 Teoría
| 2 | 🛠️ Demo: Instalar Docker Desktop en MacOS | 
| 3 | 🛠️ Demo: Instalar Docker Desktop en Windows | 
| 4 | 🧪 Demo: Mi primer contenedor con Docker Desktop | 
| 5 | 🔤 Demo: Cómo crear tus primeros contenedores desde el terminal de Docker Desktop |



## 📺 Previously on Lemoncode...

**Teoría**

Durante el vídeo de teoría hemos visto los siguientes conceptos clave:

- ¿Qué es un contenedor?
- Diferencia imagen vs contenedor
- ¿Qué es Docker?
- Arquitectura de Docker
- ¿Qué es Docker Hub?


**Docker Desktop** 

- Cómo instalar Docker Desktop en Windows y MacOS
- Conocer la interfaz de Docker Desktop
- Buscar imágenes en Docker Hub desde la GUI
- Crear primer contenedor con Nginx desde GUI
    - Le ponemos nombre
    - Le asignamos un puerto
- Ejecutar y ver logs desde la interfaz gráfica

**Docker CLI Basics** 

*Desde la Terminal de Docker Desktop*

- Comandos básicos `docker run`
- Mapeo de puertos: `p 8080:80`
- Ejecutar en segundo plano: `d`
- Diferencia entre ejecutar en foreground vs background

Ahora que ya hemos visto los vídeos, vamos a repasar algunos de los conceptos y comandos más importantes que hemos visto.

## Sección 2: Visual Studio Code para la gestión de mis contenedores (15 minutos)

Durante los vídeos pudiste ver cómo ejecutar contenedores desde Docker Desktop y el terminal del mismo. Ahora vamos a ver cómo podemos usar Visual Studio Code como entorno de trabajo. ¿Por qué? Porque es gratuito, multiplataforma y porque vamos a tener extensiones y ayuda adicional para el resto de temas que vamos a ver.

Una vez que lo tengas instalado, te recomiendo que instales la extensión llamada: **Container Tools**

![image.png](attachment:ede84805-00a0-493d-ac66-c756a716eb97:image.png)

Con ello vamos a conseguir una pestaña adicional en mi Visual Studio Code en la que voy a poder ver todos los contenedores, imágenes, etcétera

![image.png](attachment:a8bc9bb2-a2a4-4a36-a229-3ab7edb9a497:image.png)

Y por otro lado la que nos proporciona Docker

![image.png](attachment:28c7414d-7cb3-4aa4-b8e3-e22bcf5aea41:image.png)

Este nos ayudará más adelante cuando hagamos cosas un poquito más avanzadas.

Y con estos dos ya estamos listos para empezar a jugar. Creo que es importante familiarizarnos con algún IDE que tenga soporte para contenedores porque la realidad es que cuando estamos desarrollando aplicaciones, incluso Dockerizadas, es donde vamos a estar la mayor parte del tiempo. Nos iremos apoyando en estas en las siguientes prácticas.

## Sección 3: ampliando con más comandos básicos

Ahora ya conocemos al menos:

El comando que necesitamos para ejecutar un contenedor:

```jsx
docker run -p 8080:80 -d nginx
```

También vimos que es posible poner nombres a los contenedores desde la interfaz y también desde el terminal:

```jsx
docker run --name web -p 8081:80 -d nginx
```

Para listar los contenedores que se están ejecutando

```jsx
docker ps
```

Para poder listar todos los contenedores:

```jsx
docker ps -a
```

Desde la interfaz es todo mucho más sencillo, por supuesto, pero en general vamos a pasar más tiempo en el terminal, por lo que es importante que conozcas todos estos comandos. Vamos a ver algunos más que también son importantes:

### Shells interactivos

En estos dos ejemplos anteriores hemos probado con contenedores que contienen servidores web y esto hace que solo con ejecutarlos ellos ya tienen preconfigurada una instrucción, un comando, que les mantiene con vida. Sin embargo hay otro tipos de contenedores que si no le especificamos algo más como parte de `docker run` nada más intentar ejecutarlos estos se van a parar. Como por ejemplo:

```jsx
docker run ubuntu
```

Aquí, que no he indicado el -d ni nada, nada más lanzar este comando el terminal me ha sido devuelto. De hecho si lanzo el comando que me devuelve todos los contenedores:

```jsx
docker ps -a
```

Veras que el mismo existió pero que está parado ¿Y esto por qué es así? Pues en generar, imágenes que solo contienen un sistema operativo si no les dices qué comando quieres lanzar cuando se ejecuten o no te “enganchas” a los mismos la ejecución finalizará y no habrás podido hacer nada con ellos.

Así que ahora vamos a engancharnos:

```jsx
docker run -it ubuntu /bin/bash
```

Como puedes ver, con el parámetro `-it` soy capaz de decirle a Docker “Oye, quiero ejecutar este contenedor pero me quiero enganchar a él” y, en este caso, usando un terminal con el shell bash. Básicamente lo que ocurre es que soy capaz de engancharme a un terminal dentro de este contenedor y hasta que no me salga del mismo pues podré lanzar comando como si estuviera conectado a través de ssh o similar.

### Ejecutar comandos desde fuera

Si no quiero mantenerme enganchado a terminal de un contenedor como en el caso anterior, lo que puedo hacer es lanzar comandos a la vez que los creo y que cuando finalice el mismo que se pare el contenedor.

Con este veríamos la información del sistema operativo:

```jsx
docker run -it ubuntu /bin/bash -c "cat /etc/os-release"
```

Listar los archivos que hay en la home del usuario que se utiliza por defecto:

```jsx
docker run -it ubuntu /bin/bash -c "ls -la ~"
```

En estos dos casos los contenedores se crean antes o para lanzar estos comandos, pero si quiero lanzar un comando dentro de un contenedor que ya existe también es posible:

```jsx
docker exec web cat /etc/os-release
```

### Rebautizar contenedores

Y hablando de contenedores con nombre que nosotros hemos elegido, si quisieramos rebautizar otros que en su momento no le pusimos nombre podemos hacerlo de forma sencilla usando el subcomando `rename`

```jsx
docker rename NOMBRE_ANTIGUO NOMBRE_NUEVO
```

### Variables de entorno

Como te puedes imaginar, lo que hemos visto hasta ahora son ejecuciones muy básicas de los contenedores, pero en general a ese `docker run` le suelen acompañar un montón de parámetros, dependiendo del tipo de contenedor que estemos intentando ejecutar. Sin duda, las variables de entorno suelen ser de las más comunes ¿por qué? porque en general se intenta que la configuración de los contenedores sean algo personalizables, desde el timezone si necesitan la fecha y hora esos contenedores para funcionar, hasta usuarios, contraseñas, etcera.

Un ejemplo claro sería una base de datos, donde en general cuando la creo o instalo necesito de un usuario administrador y una contraseña.

```jsx
docker run --name db \
-p 1433:1433 \
-e 'ACCEPT_EULA=Y' \
-e 'SA_PASSWORD=Lem0nCode!' \
-d mcr.microsoft.com/mssql/server:2019-latest
```

En este ejemplo sencillo podemos ver lo siguiente:

- `docker run`: lanza un contenedor.
- `--name db`: nombre del contenedor.
- `-p 1433:1433` : mapea el puerto.
- `-e 'ACCEPT_EULA=Y'`: acepta la licencia.
- `-e 'SA_PASSWORD=Lem0nCode!'`: contraseña del usuario `sa`.
- `-d mcr.microsoft.com/mssql/server:2019-latest`: imagen a usar.

Para este caso, [podría utilizar la extensión MSSQL en Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-mssql.mssql) e intentar acceder a esta base de datos.

### Arrancar y parar contenedores

Por diferentes motivos, hay contenedores que una vez creaste que se pueden haber parado y contenedores que se están ejecutando y quieres pararlos.

Si quieres arrancarlos de nuevo puedes hacerlo con:

```jsx
docker start NOMBRE_O_ID_DEL_CONTENEDOR
```

y para pararlos:

```jsx
docker stop NOMBRE_O_ID_DEL_CONTENEDOR
```

### Políticas de reinicio

Algo que también es bastante interesante que conozcas es la posibilidad de poder indicar, cuando creas un contenedor, si quieres que el mismo se ejecute de manera automática cuando arrancas tu máquina. Imaginate que el día de mañana te mola esto y tienes dentro una aplicación que te gustaría que esté disponible cada vez que arrancas el ordenador.

`--restart=no`           # No reiniciar nunca (por defecto)
`--restart=always`          # Reiniciar siempre
`--restart=unless-stopped`  # Reiniciar a menos que se pare manualmente
`--restart=on-failure`      # Solo reiniciar si falla
`--restart=on-failure:3`    # Reiniciar máximo 3 veces si falla

Por ejemplo, imagínate que tengo algo así:

```jsx
docker run --name nginx-always-on -d --restart=always nginx
```

Este siempre se arrancará.

## Sección 4: Limpieza

Ahora ya hemos conseguido lanzar varios contenedores y descargar diferentes imágenes por lo que ha llegado el momento de hacer limpieza. Para ello te voy a enseñar los comandos más útiles en este sentido.

### Eliminar un contenedor

Para eliminar un solo contenedor solamente tienes que lanzar este comando:

```jsx
docker rm NOMBRE_O_ID_DEL_CONTENEDOR
```

Pero ¡ojo! para que un contenedor pueda ser eliminado usando este comando debe estar parado. En el caso de que no lo esté deberías ejecutar antes `docker stop` o bien puedes forzar su eliminación:

```jsx
docker rm -f NOMBRE_O_ID_DEL_CONTENEDOR
```

### Eliminar una imagen

Para eliminar una sola imagen el comando a ejecutar es el siguiente:

```jsx
docker rmi NOMBRE_O_ID_DE_LA_IMAGEN
```

Pero ¡ojo! solo se puede eliminar una imagen si esta no está siendo usada por ningún contenedor. 

### Eliminar todos los contenedores

Por otro lado, si lo que quieres es eliminar de un plumazo todos los contenedores que tienes en tu máquina porque has lanzado diferentes pruebas puedes hacerlo usando este comando combo:

```jsx
docker rm $(docker ps -aq)
```

La primera parte es lo que hemos visto anteriormente y la segunda lo que hace es recuperar los IDs de todos los contenedores.

### Eliminar todas las imágenes

Si quisiera hacer lo mismo para las imágenes que no están siendo usadas:

```jsx
docker rmi $(docker images -q)
```

## Sección 5: IA para ayudarnos con Docker

Como bonus a esta clase, quiero contarte de dos herramientas que te van a ser útil durante tu aprendizaje:

### Gordon AI

Se trata de un agente nuevo que está dentro de Docker Desktop, y también desde el terminal, al cual vamos a poder preguntarle sobre temas relacionados con Docker. Como por ejemplo, desde el chat de Docker Desktop podría preguntarle cosas como:

- “¿Cómo puedo ejecutar un contenedor con nginx?”

![image.png](attachment:ade79b14-613d-4738-b80b-29a2bebc89ae:image.png)

y lo mismo desde el terminal usando `docker ai`:

```jsx
docker ai "¿Cómo puedo ejecutar un contenedor con Nginx?"  
```

### GitHub Copilot

Por otro lado, barriendo para casa, también podéis usar de forma gratuita GitHub Copilot, el cual también os puede ayudar con dudas o problemas que podáis encontraros con Docker y otras tecnologías.

Y es que la IA amigos ya forma parte de nuestras vidas en diferentes formatos y cómo no iba a estar también en el mundo de los contenedores.