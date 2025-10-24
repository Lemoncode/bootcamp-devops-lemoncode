
## 🤖 Docker Model Runner: IA y modelos de lenguaje en contenedores

En los últimos tiempos Docker se ha volcado en integrar capacidades de inteligencia artificial directamente en su ecosistema. Por lo que además de poder crear y gestionar contenedores tradicionales, ahora es posible trabajar con modelos de IA y grandes modelos de lenguaje (LLMs) de forma nativa. Para ello ha creado una herramienta llamada **Docker Model Runner**, la cual te permite descargar imágenes que lo que contienen son modelos de IA listos para usar.

### ✨ **Características principales**

- **🔄 Gestión simplificada**: Descarga y sube modelos directamente desde/hacia Docker Hub
- **🌐 APIs compatibles con OpenAI**: Sirve modelos con endpoints familiares para fácil integración
- **📦 Empaquetado OCI**: Convierte archivos GGUF en artefactos OCI y publícalos en cualquier registro
- **💻 Interfaz dual**: Interactúa desde línea de comandos o la GUI de Docker Desktop
- **📊 Gestión local**: Administra modelos locales y visualiza logs de ejecución

### 🚀 **Cómo funciona**

Los modelos se descargan desde Docker Hub la primera vez que se usan y se almacenan localmente. Se cargan en memoria solo cuando se solicita y se descargan cuando no están en uso para optimizar recursos. Después de la descarga inicial, quedan en caché para acceso rápido.

### 🛠️ **Comandos esenciales**

```bash
# Habilitar Docker Model Runner (desde Docker Desktop settings)
# Beta features > Enable Docker Model Runner

# Verificar instalación
docker model version

# Ejecutar un modelo
docker model run ai/gemma3

# Listar modelos locales
docker model ls
```

### 🔗 **Modelos disponibles**

Todos los modelos están disponibles en el [namespace público de Docker Hub](https://hub.docker.com/u/ai).

### 💡 **Casos de uso típicos**

- **Desarrollo de aplicaciones GenAI**: Integra IA en tus apps sin configuración compleja
- **Prototipado rápido**: Prueba diferentes modelos localmente antes del despliegue
- **Pipelines CI/CD**: Incluye capacidades de IA en tus flujos de trabajo automatizados
- **Experimentación ML**: Testa modelos sin depender de servicios externos
