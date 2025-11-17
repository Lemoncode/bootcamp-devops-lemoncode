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


## 👀 Conociendo Docker desde Docker Desktop 🍋📺

Cuando hayas instalado Docker Desktop verás que puedes empezar de forma muy visual, aunque es posible que al principio no tengas muy claro qué es lo que tienes que hacer 😅. Aunque es recomendable dominar la línea de comandos, ya que es la forma más rápida y común de trabajar con Docker en la vida real, vamos a empezar por lo sencillo para luego ir avanzando cada vez un poco más y que te vayas sintiendo cómod@ con los diferentes conceptos.

En el vídeo [Mi primer contenedor con Docker Desktop](https://campus.lemoncode.net/#/training/68c9403afd3dcd0a256a0291/video-player/https%3A%2F%2Fd2gr4gsp182xcm.cloudfront.net%2Fcampus%2Fbootcamp-devops-vi%2Fintroduccion-modulo-2-contenedores%2F03-contenedores-i-demo-3-mi-primer-contenedor-docker-desktop.mp4) 🍋📺 podrás ver todo esto explicado paso a paso.

### 📦 Mi primer contenedor con un servidor web 🍋📺

Ahora que ya tenemos instalado todo lo que necesitamos para empezar, nuestra primera misión va a ser, lógicamente, pues crear nuestro primer contenedor 📦, como no podía ser de otra manera 😅 Y para este primer ejemplo vamos a crear un contenedor que dentro tenga un servidor web, en este caso usando [Nginx](https://nginx.org/), aunque podría ser cualquier otro, como también veremos.

Ahora mismo en nuestra instalación de Docker Desktop no tenemos absolutamente nada, así que vamos a ver paso a paso cómo podemos crear este contenedor desde aquí.

Lo primero que necesitas es saber la imagen que podemos utilizar para tener un contenedor con Nginx ¿Y cómo puedo saber esto? Pues para ello tenemos que ir la sección llamada **Docker Hub** dentro de Docker Desktop:

![Docker Hub en Docker Desktop](imagenes/Docker%20Hub%20en%20Docker%20Desktop.png)

Aquí vas a poder ver que tenemos un buscador donde podemos investigar qué imágenes hay disponibles, listas para usar. Por lo que si busco por `nginx` seré capaz de encontrar lo que busco.

![nginx Docker Hub en Docker Desktop](imagenes/Nginx_en%20Docker%20Hub.png)

Si hago clic sobre la misma...

![Información sobre la imagen de Nginx](imagenes/Información%20sobre%20la%20imagen%20de%20nginx.png)

Podrás ver información relacionada con la imagen, como por ejemplo las etiquetas disponibles, la descripción de la misma, etc. Ya entraremos más en detalle en todo esto, pero por ahora lo que nos interesa es ejecutar un contenedor que utilice la misma, así que vamos a ejecutar el botón **Run** que aparece en la parte superior derecha de la pantalla.

Al hacerlo ocurriran dos cosas:

1. En la parte inferior dice que está haciendo pull de la imagen, es decir, descargándola 📥 a tu máquina local.
2. Te aparecerá un dialogo donde te pide un par de valores y la opción de ejecutar el contenedor.

![Ejecutar contenedor de Nginx](imagenes/Ejecutar%20un%20nuevo%20contenedor%20desde%20Docker%20Desktop.png)

Como por ahora no tenemos mucha idea, vamos a hacer clic directamente sobre el botón **Run** y veremos qué ocurre. Si todo ha ido bien, deberías ver en la sección de **Containers** que ya tienes un contenedor en ejecución 🚀

Cuando tienes un contenedor en ejecución verás que esté se está ejecutando porque tiene un circulo verde al lado del nombre. Pero como puedes ver, también se pueden parar, e incluso eliminar, contenedores. Además si hacemos clic sobre los tres puntos que aparecen al lado del nombre del contenedor, veremos que podemos acceder a más opciones, como por ejemplo ver los logs del contenedor, abrir una terminal dentro del mismo, etc. Y más recientemente también puedes ver que aparecen unas estrellitas ✨ al lado del botón de parada, que es el acceso rápido a **Gordon** el asistente IA de Docker que te ayudará a resolver dudas y problemas comunes. Lo veremos también con cariño más adelante para que puedas sacarle también partido y te ayude a aprender más sobre Docker.

>[!IMPORTANT]
>Es muy importante que tengas en cuenta que una imagen no es un contenedor. Es decir, que yo podría repetir este proceso varias veces y crear varios contenedores a partir de la misma imagen, cada uno con su propia configuración, estado, etc. Por ejemplo, si vuelves a hacer clic en el botón **Run** verás que te aparece un nuevo diálogo donde puedes configurar el nombre del contenedor, los puertos que quieres mapear, etc. Podríamos decir que una imagen es como una plantilla, y un contenedor es una instancia de esa plantilla.


Vale, ya tengo uno o varios contenedores con nginx, pero si ahora accedo a http://localhost no tengo ningun servidor web funcionando, ¿por qué? pues porque estos contenedores viven en un entorno aislado, y para poder acceder a ellos desde mi máquina local tengo que mapear los puertos del contenedor a los de mi máquina. Esto lo veremos más adelante, pero por ahora vamos a ver cómo podemos hacer esto desde la interfaz gráfica de Docker Desktop.

Si ahora vuelvo a crear un nuevo contenedor y hago clic en el botón **Run** de nuevo, verás que en el diálogo que aparece un cuadro de texto donde puedo proporcionar un puerto.

![Crear un contenedor indicando un puerto de mapeo](imagenes/Crear%20un%20contenedor%20indicando%20un%20puerto%20de%20mapeo.png)

A lo que se refiere es a un puerto de mi máquina local que esté libre por el cual yo quiera/pueda acceder a este nuevo contenedor que voy a crear. En mi ejemplo he usado el puerto 8080 pero podría ser cualquier otro por encima de 1024, ya que los puertos por debajo de este número suelen estar reservados para servicios del sistema operativo.

Al ejecutar el comando **Run** verás que en la sección de **Containers** aparece un nuevo contenedor pero este es diferente al resto, ya que tiene un enlace a un puerto de tu máquina local, en este caso el 8080. 

![Crear un contenedor indicando un puerto de mapeo](imagenes/Containers%20-%20contenedor%20con%20puerto%20mapeado.png)

Si haces clic sobre el enlace podrás acceder al servidor web que has creado con Nginx.

![Acceso al servidor web de Nginx](imagenes/En%20localhost%208080%20Welcome%20to%20Nginx.png)


¡🎉 Enhorabuena! Has creado tu primer contenedor con un servidor web Nginx. Pero esto es solo el principio. A medida que avancemos, aprenderás a personalizar y gestionar tus contenedores de manera más efectiva.

Y ahora que ya lo has visto todo desde la interfaz gráfica de Docker Desktop, vamos a ver cómo podemos hacer lo mismo pero desde la línea de comandos, que es la forma más común de trabajar con Docker en la vida real. Para ello, abre el terminal integrado de Docker Desktop haciendo clic en el icono de la terminal en la parte superior derecha de la ventana:

![Terminal integrado en Docker Desktop](imagenes/Terminal%20integrado%20en%20Docker%20Desktop.png)

## 🐳 Docker CLI 🍋📺

Docker CLI (Command Line Interface) es la herramienta que te permite interactuar con Docker desde la línea de comandos. Aunque Docker Desktop ofrece una interfaz gráfica, es recomendable familiarizarse con el CLI para aprovechar al máximo las capacidades de Docker. 

Para hacer lo mismo que hicimos antes desde la interfaz gráfica, vamos a usar el comando `docker run` para crear un contenedor con Nginx. Abre el terminal integrado de Docker Desktop y ejecuta el siguiente comando:

```bash
docker run nginx
```

Este comando descargará la imagen de Nginx (si no la tienes ya) y creará un contenedor a partir de ella. Sin embargo, a este nuevo contenedor le ocurrirá lo mismo que a los que creamos inicialmente y es que no podremos acceder a él desde nuestro navegador, ya que no hemos mapeado ningún puerto. Así que vamos a hacer lo mismo que hicimos antes pero ahora desde la línea de comandos.

Para mapear el puerto del contenedor al de tu máquina local, usa el siguiente comando:

```bash
docker run --publish 8080:80 nginx
```

Por otro lado, en estos dos casos te darás cuenta de que el terminal queda "bloqueado" y no puedes hacer nada más hasta que pares el contenedor. Esto es porque Nginx es un servidor web que necesita estar activo para poder responder a las peticiones. Si quieres ejecutar el contenedor en segundo plano, puedes usar la opción `-d` o `--detach`:

```bash
docker run --detach --publish 8080:80 nginx
```

Y hasta aquí la parte introductoria que pudiste ver en los vídeos del campus. A partir de aquí, vamos a seguir viendo más comandos y opciones que te permitirán gestionar tus contenedores de manera más efectiva.

Ahora que ya hemos visto los vídeos, vamos a repasar algunos de los conceptos y comandos más importantes que hemos visto.

## Sección 2: Visual Studio Code para la gestión de mis contenedores

Durante los vídeos pudiste ver cómo ejecutar contenedores desde Docker Desktop y el terminal del mismo. Ahora vamos a ver cómo podemos usar Visual Studio Code como entorno de trabajo. ¿Por qué? Porque es gratuito, multiplataforma y porque vamos a tener extensiones y ayuda adicional para el resto de temas que vamos a ver.

Una vez que lo tengas instalado, te recomiendo que instales la extensión llamada: **Container Tools**

![Docker Hub en Docker Desktop](imagenes/Extension%20Container%20Tools.png)

Con ello vamos a conseguir una pestaña adicional en mi Visual Studio Code en la que voy a poder ver todos los contenedores, imágenes, etcétera

![Docker Hub en Docker Desktop](imagenes/Cómo%20se%20ve%20la%20sección%20de%20container%20tools.png)

Y por otro lado la que nos proporciona Docker, llamada Docker DX:

![Docker DX](imagenes/Extension%20Docker%20DX.png)

Este nos ayudará más adelante cuando hagamos cosas un poquito más avanzadas.

Y con estos dos ya estamos listos para empezar a jugar. Creo que es importante familiarizarnos con algún IDE que tenga soporte para contenedores porque la realidad es que cuando estamos desarrollando aplicaciones, incluso Dockerizadas, es donde vamos a estar la mayor parte del tiempo. Nos iremos apoyando en estas en las siguientes prácticas.

## Sección 3: Ampliando con más comandos básicos

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

- `--restart=no`           # No reiniciar nunca (por defecto)
- `--restart=always`          # Reiniciar siempre
- `--restart=unless-stopped`  # Reiniciar a menos que se pare manualmente
- `--restart=on-failure`      # Solo reiniciar si falla
- `--restart=on-failure:3`    # Reiniciar máximo 3 veces si falla

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

## 📋 Ejercicios propuestos

### Ejercicio 1: Mi primer Nginx (Muy básico)
Objetivo: Crear y acceder a tu primer contenedor web

**Pasos:**
1. Ejecuta `docker run -d -p 8080:80 nginx`
2. Verifica que el contenedor está corriendo con `docker ps`
3. Accede a `http://localhost:8080` en tu navegador
4. Deberías ver la página "Welcome to nginx"
5. Para el contenedor con `docker stop`

**Conceptos practicados:** `docker run`, mapeo de puertos (`-p`), `docker ps`, `docker stop`

---

### Ejercicio 2: Listar, renombrar y limpiar
Objetivo: Practicar los comandos básicos de gestión de contenedores

**Pasos:**
1. Crea 2-3 contenedores nginx sin mapear puertos: `docker run -d nginx` (repite 2-3 veces)
2. Lista todos los contenedores: `docker ps -a`
3. Renombra uno de ellos: `docker rename NOMBRE_ANTIGUO mi-nginx-renombrado`
4. Elimina los contenedores que creaste: `docker rm NOMBRE_O_ID`
5. Verifica que desaparecieron: `docker ps -a`

**Conceptos practicados:** `docker ps -a`, `docker rename`, `docker rm`

---

### Ejercicio 3: Comparando servidores web: Nginx vs Apache
Objetivo: Explorar diferentes imágenes y ver cómo se ve cada servidor web

**Pasos:**
1. Crea un contenedor con Apache: `docker run -d --name apache-server -p 8081:80 httpd`
2. Crea un contenedor con Nginx: `docker run -d --name nginx-server -p 8082:80 nginx`
3. Accede a ambos en tu navegador:
   - Apache: `http://localhost:8081`
   - Nginx: `http://localhost:8082`
4. Observa las diferencias en las páginas de bienvenida
5. Lista los contenedores con `docker ps`
6. Para y elimina ambos contenedores

**Conceptos practicados:** Diferentes imágenes, naming (`--name`), mapeo de puertos, comparación de alternativas