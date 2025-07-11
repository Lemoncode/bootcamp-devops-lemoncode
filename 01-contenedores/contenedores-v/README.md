# Día V: Docker Networking - ¡Conectando contenedores como un jefe! 🕸️

![Docker](imagenes/Docker%20y%20el%20networking.png)

¡Bienvenido al fascinante mundo de las redes en Docker! 🎉 Como este es un tema que asusta un poco, he preferido hacerlo algo más ameno.

Hoy vamos a aprender cómo nuestros contenedores pueden hablar entre ellos, desde susurros secretos hasta conversaciones a gritos que todo el mundo puede escuchar. Prepárate para convertirte en el casamentero de contenedores más famoso del barrio. 💕

## 📋 Agenda

- [🤔 ¿Qué diablos es esto del networking?](#-qué-diablos-es-esto-del-networking)
- [🌉 La red bridge: El barrio por defecto (y por qué no es tan genial)](#-la-red-bridge-el-barrio-por-defecto-y-por-qué-no-es-tan-genial)
- [🏘️ Redes VIP: Creando barrios exclusivos para tus contenedores](#️-redes-vip-creando-barrios-exclusivos-para-tus-contenedores)
- [🤝 Contenedores bilingües: Hablando en múltiples redes](#-contenedores-bilingües-hablando-en-múltiples-redes)
- [🚪 Port Mapping: Abriendo puertas al mundo exterior](#-port-mapping-abriendo-puertas-al-mundo-exterior)
- [🏠 Red Host: Cuando tu contenedor se muda a tu casa](#-red-host-cuando-tu-contenedor-se-muda-a-tu-casa)
- [🏝️ Contenedores ermitaños: Viviendo sin WiFi](#️-contenedores-ermitaños-viviendo-sin-wifi)
- [🧹 Limpieza de redes: Marie Kondo para Docker](#-limpieza-de-redes-marie-kondo-para-docker)
- [🎭 Los diferentes tipos de redes: Eligiendo tu estilo](#-los-diferentes-tipos-de-redes-eligiendo-tu-estilo)
- [🎉 ¡Felicidades, eres oficialmente un ninja de redes!](#-felicidades-eres-oficialmente-un-ninja-de-redes)

## 🚀 Antes de empezar: Preparación Express

Para aprovechar al máximo estas 2.5 horas de networking ninja, asegúrate de tener todo listo:

### ✅ **Prerequisitos técnicos:**
```bash
# Verificar que Docker funciona
docker run hello-world

# Pre-descargar las imágenes que usaremos (ahorra tiempo en clase)
docker pull nginx
docker pull httpd
docker pull alpine

# Instalar jq para visualizar JSON bonito (opcional pero recomendado)
# En macOS: brew install jq
# En Ubuntu: sudo apt install jq
# En Windows: choco install jq
```

### ⏱️ **Distribución de tiempo recomendada:**
- **Conceptos básicos y bridge** (45 min)
- **Redes personalizadas** (45 min) 
- **Port mapping y casos especiales** (45 min)
- **Limpieza y Q&A** (15 min)

### 🎯 **Para instructores:**
- Tener un entorno Docker limpio antes de empezar
- Considerar hacer las demos en vivo vs. mostrar resultados pre-preparados
- Preparar ejemplos de troubleshooting comunes

---

## 🤔 ¿Qué diablos es esto del networking?

Imagínate que tus contenedores son como vecinos en un edificio. Algunos viven en el mismo piso y pueden hablar por la pared, otros necesitan el intercomunicador, y algunos están tan antisociales que ni siquiera tienen timbre. Docker networking es básicamente el sistema de comunicación de este edificio de contenedores. 🏢

### 🕵️ Espiando las redes disponibles

Primero, vamos a ver qué "barrios" tenemos disponibles en nuestro host. Es como hacer un censo, pero más divertido:

```bash
docker network ls
```

**¿Qué vamos a encontrar en nuestro censo?** 📊
- `bridge`: El barrio por defecto (piensa en él como "Las Flores", básico pero funcional)
- `host`: El barrio donde todos comparten casa con el anfitrión 
- `none`: El barrio de los ermitaños (sin WiFi, sin problemas)

## 🌉 La red bridge: El barrio por defecto (y por qué no es tan genial)

La red `bridge` es como ese barrio de clase media donde todos los contenedores van a parar cuando no especificas nada más. Es funcional, pero tiene sus... peculiaridades. 🤷‍♂️

### 🚨 ¡Alerta de spoiler!
Esta red **NO es la opción premium** para entornos de producción. Es como usar Internet Explorer en 2024: funciona, pero hay mejores opciones. 😅

### 🔍 Demo 1: Espiando a los vecinos del bridge

Vamos a fisgar un poco y ver cómo está configurado este barrio:

```bash
# Mirando los planos del barrio bridge
docker network inspect bridge

# Versión más bonita (si tienes jq instalado, sino... ¡instálalo!)
docker network inspect bridge --format '{{json .Containers}}' | jq
```

### 🏠 Demo 2: Mudando inquilinos al barrio bridge

Vamos a meter algunos contenedores en este barrio y ver cómo se llevan:

```bash
# Primer inquilino: Nginx (el vecino silencioso)
docker run -d --name web nginx

# Segundo inquilino: Apache (el vecino ruidoso)
docker run -d --name web-apache httpd

# ¿Quién vive aquí? ¡Vamos a verlo!
docker ps

# Chismoseando quién está conectado al barrio bridge
docker network inspect bridge --format '{{json .Containers}}' | jq
```

### 💬 Demo 3: Intentando que los vecinos se hablen

Ahora viene la parte divertida. Vamos a intentar que nuestros contenedores se comuniquen. Spoiler: va a ser como intentar que tu abuelo use TikTok. 😂

```bash
# Entrando en la casa del vecino Nginx
docker exec -ti web /bin/bash

# Instalando el "kit de supervivencia social" (herramientas de red)
apt update && apt -y install net-tools iputils-ping

# Viendo las "ventanas" de red de nuestro contenedor
ifconfig

# Haciendo ping por IP (esto SÍ funciona, como gritar por la ventana)
ping 172.17.0.3

# Intentando llamar por nombre (esto NO funciona, como si no supiera el nombre del vecino)
ping web-apache

# Saliendo de la casa del vecino (antes de que se moleste)
exit
```

**🤔 ¿Qué acabamos de aprender?** En el barrio bridge básico, los contenedores pueden comunicarse por IP (como gritar el número de apartamento), pero **NO por nombre** (como si fueran antisociales y no se presentaran). 

## 🏘️ Redes VIP: Creando barrios exclusivos para tus contenedores

¡Ahora sí que vamos a ponernos serios! Las redes personalizadas son como crear un barrio privado donde todos se conocen por nombre y hasta se saludan por la mañana. ☕

### 🌟 ¿Por qué las redes VIP son mejores que el barrio común?
- ✅ **DNS automático**: Los contenedores se conocen por nombre (¡como gente civilizada!)
- ✅ **Mejor seguridad**: Aislamiento total del resto de plebs
- ✅ **Control total**: Tú decides quién entra y quién sale
- ✅ **Flexibilidad**: Puedes conectar y desconectar inquilinos cuando quieras

### 🏗️ Demo 4: Construyendo nuestro barrio VIP

Vamos a crear nuestro propio barrio exclusivo. Lo llamaremos "Lemoncode Estates" porque somos fancy así: 💅

```bash
# Creando nuestro barrio VIP
docker network create lemoncode-net

# Verificando que nuestro barrio está en el mapa
docker network ls

# Inspeccionando los planos de nuestro nuevo barrio
docker network inspect lemoncode-net
```

### 🏡 Demo 5: Mudando inquilinos VIP

Ahora vamos a meter algunos contenedores en nuestro barrio exclusivo:

```bash
# Primer inquilino VIP: Nginx Premium
docker run -d --name web2 --network lemoncode-net nginx

# Entrando a visitar a nuestro inquilino VIP
docker exec -ti web2 /bin/bash

# Instalando las herramientas VIP
apt update && apt -y install net-tools iputils-ping

# Viendo las conexiones premium
ifconfig

# Intentando hablar con los plebeyos del barrio común (NO va a funcionar)
ping 172.17.0.2

exit
```

```bash
# Segundo inquilino VIP: Apache Premium
docker run -d --name web-apache2 --network lemoncode-net httpd

# Verificando que ambos están en nuestro barrio VIP
docker network inspect lemoncode-net
```

### 🎉 Demo 6: ¡La magia de la comunicación VIP!

Ahora viene el momento mágico. Nuestros contenedores VIP van a comunicarse como personas civilizadas:

```bash
# Visitando de nuevo a nuestro inquilino Nginx VIP
docker exec -ti web2 /bin/bash

# Ping por IP (el método tradicional, sigue funcionando)
ping 172.18.0.3

# ¡Y ahora la magia! Ping por nombre (¡FUNCIONA!)
ping web-apache2

# Incluso podemos hacer una visita HTTP de cortesía
curl http://web-apache2

exit
```

**� ¡BOOM!** ¡Magia pura! En los barrios VIP, ¡los contenedores se conocen por nombre! Es como si hubieran ido a la misma escuela. 

## 🤝 Contenedores bilingües: Hablando en múltiples redes

¿Y si te dijera que un contenedor puede vivir en DOS barrios a la vez? Es como ser bilingüe, pero para redes. Vamos a convertir a nuestro contenedor en un cosmopolita. 🌍

### 🌉 Demo 7: El contenedor que vive en dos mundos

```bash
# Conectando nuestro web2 al barrio plebeyo también
docker network connect bridge web2

# Verificando que ahora es ciudadano de dos barrios
docker network inspect bridge

# Entrando a ver su nueva doble vida
docker exec -ti web2 /bin/bash

# Viendo todas sus "casas" (ahora tiene múltiples interfaces)
ifconfig

# Ahora puede hablar con TODOS los vecinos
ping 172.17.0.2  # Los del barrio plebeyo
ping 172.18.0.2  # Los del barrio VIP

exit
```

**🤯 ¡Mind blown!** Nuestro contenedor ahora es como esa persona popular que tiene amigos en todos los grupos sociales.

## 🚪 Port Mapping: Abriendo puertas al mundo exterior

Hasta ahora nuestros contenedores han estado charlando entre ellos como en una fiesta privada. Pero a veces necesitas que el mundo exterior pueda visitarlos. Aquí es donde entra el port mapping, que es básicamente como poner un portero en la entrada. 🕴️

### 🔓 Demo 8: Abriendo la puerta principal

```bash
# Creando un contenedor con puerta al mundo exterior
docker run -d -p 9090:80 nginx
```

**🎉 ¡Voilà!** Ahora cualquiera puede visitar tu nginx en `http://localhost:9090`. Es como tener una casa con dirección pública.

### 🏗️ Demo 9: El truco del Dockerfile con EXPOSE

Primero, vamos a crear un Dockerfile que es como el plano de nuestra casa con todas las puertas marcadas:

```dockerfile
FROM nginx
EXPOSE 80
EXPOSE 443
```

```bash
# Construyendo nuestra casa personalizada
docker build -t nginx-custom .

# Espiando los planos para ver qué puertas tiene
docker inspect nginx-custom

# ¡Abriendo TODAS las puertas automáticamente! (modo fiesta)
docker run -d --publish-all nginx-custom
# O la versión para perezosos:
docker run -d -P nginx-custom

# Viendo qué puertas se abrieron
docker ps

# Siendo específicos sobre las puertas
docker port <CONTAINER_ID>
```

## 🏠 Red Host: Cuando tu contenedor se muda a tu casa

La red `host` es como cuando tu primo se viene a vivir contigo y usa tu WiFi, tu nevera, y básicamente todo lo tuyo. El contenedor literalmente se muda a la red de tu máquina. 🏡

### 🤲 Demo 10: El contenedor que se muda contigo

```bash
# Creando un contenedor que literalmente vive en tu casa
docker run -d --name web-apache3 --network host httpd

# Verificando que efectivamente está en tu casa
docker network inspect host
```

**⚠️ ¡Cuidado!** En modo host, tu contenedor usa directamente los puertos de tu máquina. Es como dejarle las llaves de casa a tu primo.

## 🏝️ Contenedores ermitaños: Viviendo sin WiFi

A veces tienes contenedores que son como ese tío ermitaño que vive en la montaña sin Internet. No necesitan hablar con nadie, solo hacer su trabajo en silencio. 🧙‍♂️

### 🚫 Demo 11: El contenedor antisocial

```bash
# Creando un contenedor totalmente antisocial
docker run -dit --network none --name no-net-alpine alpine ash

# Verificando que efectivamente es un ermitaño
docker exec no-net-alpine ip link show
```

**🔍 ¡Efectivamente!** Solo verás la interfaz `lo` (loopback). Es como tener un teléfono que solo puede llamarse a sí mismo.

## 🧹 Limpieza de redes: Marie Kondo para Docker

Cuando termines de jugar con las redes, es importante limpiar. Es como después de una fiesta: hay que recoger. 🎊➡️🧹

### 🗑️ Eliminando redes específicas

```bash
# Eliminando nuestro barrio VIP (primero echa a los inquilinos)
docker network rm lemoncode-net

# Haciendo limpieza general de redes huérfanas
docker network prune
```

**💡 Pro tip:** Docker es como ese amigo ordenado que no te deja eliminar una red si aún hay contenedores viviendo en ella.

## 🎭 Los diferentes tipos de redes: Eligiendo tu estilo

Como en la vida real, hay diferentes estilos de barrios para diferentes necesidades:

### 🌉 Bridge
- **¿Para qué?** Aplicaciones en una sola máquina (el típico apartamento compartido)
- **¿Cómo es?** Aislamiento de red, comunicación entre contenedores

### 🏠 Host
- **¿Para qué?** Cuando necesitas máximo rendimiento (como mudarte con tus padres para ahorrar)
- **¿Cómo es?** Sin aislamiento, comparte todo con el anfitrión

### 🚫 None
- **¿Para qué?** Contenedores que no necesitan red (los ermitaños digitales)
- **¿Cómo es?** Sin conectividad de red

### 🌐 Overlay
- **¿Para qué?** Aplicaciones que viven en múltiples máquinas (como tener casas en diferentes países)
- **¿Cómo es?** Comunicación entre contenedores en diferentes hosts

### 🚀 Demo 12: El intento épico de crear una red overlay

```bash
# Esto va a fallar espectacularmente (y está bien)
docker network create --driver overlay multihost-net
```

**🤷‍♂️ ¿Por qué falló?** Porque las redes overlay necesitan Docker en modo "grupo de trabajo" (Docker Swarm). Es como intentar organizar una fiesta internacional sin coordinación previa.

## 🎯 Resumen de supervivencia para networking en Docker

Como todo buen manual de supervivencia, aquí tienes las reglas de oro:

1. **🏘️ Usa redes VIP** en lugar del barrio plebeyo bridge
2. **👥 Agrupa a la familia** - contenedores relacionados en la misma red
3. **📞 Llama por nombre** - usa nombres de contenedores para comunicación interna
4. **🚪 Solo abre las puertas necesarias** - mapea puertos solo cuando los necesites
5. **🏃‍♂️ Usa red host con moderación** - solo para casos de alto rendimiento
6. **🧹 Limpia regularmente** - nadie quiere redes huérfanas por ahí

## � Limpieza post-fiesta

Después de todas estas demos, tu Docker va a parecer después de una fiesta universitaria. Hora de limpiar:

```bash
# Parando toda la fiesta
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)

# Limpiando las redes
docker network prune

# Eliminando nuestras creaciones artísticas
docker rmi nginx-custom
```

---

## 📚 Enlaces para seguir aprendiendo (porque somos nerds)

- [Documentación oficial de Docker Network](https://docs.docker.com/network/) - La biblia
- [Docker Network Drivers](https://docs.docker.com/network/drivers/) - Los diferentes sabores
- [Docker Compose Networking](https://docs.docker.com/compose/networking/) - Nivel siguiente

---

## 🎉 ¡Felicidades, eres oficialmente un ninja de redes!

En esta épica aventura de networking has aprendido a:

- 🕵️ **Espiar redes disponibles** como un verdadero detective de Docker
- 🌉 **Dominar la red bridge** (y entender por qué es básica)
- �️ **Crear barrios VIP** donde los contenedores se conocen por nombre
- 🤝 **Hacer contenedores bilingües** que viven en múltiples redes
- 🚪 **Abrir puertas al mundo exterior** con port mapping como un portero profesional
- 🏠 **Mudarte con tus contenedores** usando la red host
- 🏝️ **Crear ermitaños digitales** con contenedores sin red
- 🧹 **Limpiar como Marie Kondo** para mantener Docker organizado
- 🎭 **Elegir el estilo de red perfecto** para cada situación

Ahora ya no eres solo alguien que ejecuta contenedores. ¡Eres el arquitecto de redes, el casamentero de contenedores, el ninja del networking! 🥷

En la siguiente clase seguiremos escalando en el mundo de Docker. Mientras tanto, ¡practica conectando contenedores como si fueras el Cupido de la tecnología! 💘

Happy networking! {🍋}
