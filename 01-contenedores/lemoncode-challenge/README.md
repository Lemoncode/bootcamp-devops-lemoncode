# 🐳 Laboratorio Contenedores - Retos del final del módulo 🕵🏻‍♀️🫆

![Laboratorio Docker](images/Laboratorio%20Docker.png)

>[!IMPORTANT]
> Antes de lanzarte a contenerizar todo, ¡relájate y prueba la aplicación tal como está! 😌 Lo único que necesitas es tener MongoDB funcionando. Empieza con el **Reto 1** creando MongoDB en Docker. A partir de aquí ya estás list@ para comprobar lo que has aprendido.

## 🎯 Los 4 Retos

Vas a dockerizar una aplicación completa dentro de [lemoncode-challenge](./), que está compuesta de 3 partes increíbles:

- 🌐 **Frontend**: Una interfaz con Node.js
- ⚙️ **Backend**: Elige tu aventura - .NET (`dotnet-stack`) o Node.js (`node-stack`) que se conecta con MongoDB
- 🗄️ **Base de datos**: MongoDB para almacenar toda la información

> 💡 **¡Libertad de elección!** Como habrás notado, tienes dos carpetas: `dotnet-stack` y `node-stack`. El frontend es idéntico en ambos casos, solo cambia el backend. ¡Elige el que más te motive!

---

### 🔥 Reto 1: MongoDB en Contenedor

**Objetivo**: Ejecutar MongoDB dentro de un contenedor y conectar el backend (ejecutándose localmente) para que pueda recuperar, crear, modificar y eliminar Topics.

#### 📋 Requisitos:
1. ✅ Crear una red Docker para la comunicación
2. ✅ Ejecutar MongoDB en un contenedor con persistencia de datos
3. ✅ Crear la base de datos `TopicstoreDb` con la colección `Topics`
4. ✅ Ejecutar el backend localmente conectándose a MongoDB
5. ✅ Verificar que el CRUD funciona correctamente

#### 💡 Tips:
- Usa MongoDB Compass o la extensión [MongoDB for VS Code](https://marketplace.visualstudio.com/items?itemName=mongodb.mongodb-vscode) para añadir datos
- Para ejecutar el backend localmente:
  - .NET stack: `dotnet run` 
  - Node.js stack: `npm install && npm start`
- Estructura de documento esperada:
```json
{
  "_id": { "$oid" : "5fa2ca6abe7a379ec4234883" },
  "topicName" : "Contenedores"
}
```

---

### 🐳 Reto 2: Dockerizar el Backend

**Objetivo**: Crear un Dockerfile para el backend y ejecutarlo en contenedor, conectado a MongoDB via red Docker.

#### 📋 Requisitos:
1. ✅ Crear un Dockerfile para el backend (tanto para .NET como para Node.js)
2. ✅ Construir la imagen del backend
3. ✅ Ejecutar el backend en un contenedor en la red Docker
4. ✅ Verificar que se conecta correctamente a MongoDB
5. ✅ Exponerse el puerto 5000 para que sea accesible

#### 💡 Tips:
- Define variables de entorno adecuadas para la conexión a MongoDB
- Asegúrate de que la imagen sea lo más eficiente posible
- Usa puertos correctos (5000 para la API)

---

### 🎨 Reto 3: Dockerizar el Frontend

**Objetivo**: Crear un Dockerfile para el frontend y ejecutarlo en contenedor, conectado al backend via red Docker.

#### 📋 Requisitos:
1. ✅ Crear un Dockerfile para el frontend
2. ✅ Construir la imagen del frontend
3. ✅ Ejecutar el frontend en un contenedor en la red Docker
4. ✅ Configurar las variables de entorno para conectarse al backend en `http://topics-api:5000/api/topics`
5. ✅ Acceder a la interfaz desde el navegador en el puerto 8080

#### 💡 Tips:
- El frontend debe ser accesible desde http://localhost:8080
- Configura las variables de entorno para apuntar al backend correcto
- Considera usar un servidor web lightweight (como nginx) para servir los archivos

---

### 🎪 Reto 4: Docker Compose - Todo Junto

**Objetivo**: Usar Docker Compose para orquestar todos los servicios (MongoDB, Backend, Frontend) como un director de orquesta.

#### 📋 Requisitos:
1. ✅ Crear un `docker-compose.yml` que incluya los tres servicios
2. ✅ Configurar la red compartida `lemoncode-network`
3. ✅ Definir volúmenes para persistencia de MongoDB
4. ✅ Establecer todas las variables de entorno necesarias
5. ✅ Exponer los puertos correctos (8080 para frontend, 5000 para API, 27017 para MongoDB)
6. ✅ Definir dependencias entre servicios
7. ✅ Levantar toda la aplicación con un único comando
8. ✅ Acceder a la aplicación desde el navegador en http://localhost:8080

#### 💡 Tips:
- Usa `depends_on` para ordenar el inicio de los servicios
- Mapea volúmenes para persistencia de datos
- Define claramente las variables de entorno para cada servicio
- Documenta los comandos útiles (up, down, logs, etc.)

---

## 📚 Estructura de Archivos

```
lemoncode-challenge/
├── README.md (este archivo)
├── node-stack/
│   ├── backend/
│   │   └── ...
│   └── frontend/
│       └── ...
└── dotnet-stack/
    ├── backend/
    │   └── ...
    └── frontend/
        └── ...
```

---

## 🎯 Resumen de Pasos Recomendados

1️⃣ **Primero**: Completa el **Reto 1** - MongoDB corriendo localmente
2️⃣ **Segundo**: Completa el **Reto 2** - Backend en Docker
3️⃣ **Tercero**: Completa el **Reto 3** - Frontend en Docker  
4️⃣ **Cuarto**: Completa el **Reto 4** - Todo orquestado con Docker Compose

¡Demuestra que eres un maestro de la orquestación de contenedores! 🎭✨

¡Es hora de poner en práctica todo lo aprendido! 💪 Vas a dockerizar una aplicación completa dentro de [lemoncode-challenge](./), que está compuesta de 3 partes increíbles:

- 🌐 **Frontend**: Una interfaz con Node.js
- ⚙️ **Backend**: Elige tu aventura - .NET (`dotnet-stack`) o Node.js (`node-stack`) que se conecta con MongoDB
- 🗄️ **Base de datos**: MongoDB para almacenar toda la información

> 💡 **¡Libertad de elección!** Como habrás notado, tienes dos carpetas: `dotnet-stack` y `node-stack`. El frontend es idéntico en ambos casos, solo cambia el backend. ¡Elige el que más te motive!

### 📋 Misión: Cumple estos requisitos

1. 🌐 Los tres componentes deben vivir en armonía en una red llamada `lemoncode-challenge`
2. 🔗 El backend debe comunicarse con MongoDB usando esta URL mágica: `mongodb://some-mongo:27017`
3. 🚀 El frontend debe conectar con la API mediante: `http://topics-api:5000/api/topics`
4. 🌍 El frontend debe ser accesible desde tu navegador en el puerto `8080`
5. 💾 MongoDB debe persistir los datos en un volumen mapeado a `/data/db`
6. 📊 Crea una base de datos llamada `TopicstoreDb` con una colección `Topics` que tenga esta estructura:

```json
{
  "_id": { "$oid" : "5fa2ca6abe7a379ec4234883" },
  "topicName" : "Contenedores"
}
```

🎉 **¡No olvides añadir varios registros para hacer tu app más interesante!**

__Tip para backend__: Antes de intentar contenerizar y llevar a cabo todos los pasos del ejercicio se recomienda intentar ejecutar la aplicación sin hacer cambios en ella. En este caso, lo único que es posible que “no tengamos a mano” es el MongoDB. Por lo que empieza por crear este en Docker, usa un cliente como MongoDB Compass para añadir datos que pueda devolver la API.

![Mongo compass](./images/mongodbcompass.png)

> 💎 **Pro Tip**: Abre Visual Studio Code directamente desde la carpeta `backend` para hacer las pruebas. ¡Te ahorrará tiempo! Para ejecutar el código:
> - .NET stack: `dotnet run` 
> - Node.js stack: `npm install && npm start`

**🎨 Para el Frontend**: 
Abre la carpeta frontend en VS Code y ejecuta `npm install` para instalar las dependencias. Luego `npm start` y ¡voilà! Tu navegador debería mostrar algo así:

![Topics](./images/topics.png)

## 🎪 Misión 2: ¡Docker Compose al Rescate!

¡Ahora viene la parte divertida! 🎊 Toma tu aplicación dockerizada de la misión 1 y usa Docker Compose para orquestar todas las piezas como un director de orquesta.

### 🎯 Tu misión incluye:
- 🌐 Configurar la red que conecta todos los servicios
- 💾 Definir el volumen que necesita MongoDB para persistir datos
- 🔧 Establecer las variables de entorno necesarias
- 🚪 Exponer los puertos correctos para web y API
- 📝 Documentar los comandos para levantar, parar y eliminar el entorno

¡Demuestra que eres un maestro de la orquestación de contenedores! 🎭✨
