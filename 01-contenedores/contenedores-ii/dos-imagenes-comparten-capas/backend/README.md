# Backend - API REST en PHP

Servidor PHP super básico que expone una API REST con datos de ejemplo.

## 📋 Descripción

Este backend proporciona un único endpoint GET que retorna una lista de TODOs en formato JSON.

## 🔧 Configuración

- **Lenguaje:** PHP
- **Tipo:** API REST
- **Formato:** JSON
- **CORS:** Habilitado

## 📡 Endpoints

### GET /backend/api.php

Retorna todos los TODOs disponibles.

**Ejemplo de solicitud:**
```bash
curl http://localhost:8000/backend/api.php
```

**Respuesta exitosa (200):**
```json
{
  "exito": true,
  "mensaje": "Todos obtenidos correctamente",
  "datos": [
    {
      "id": 1,
      "titulo": "Aprender PHP",
      "completado": false,
      "fecha": "2025-10-23"
    },
    {
      "id": 2,
      "titulo": "Crear una API REST",
      "completado": true,
      "fecha": "2025-10-22"
    }
  ],
  "cantidad": 4
}
```

**Respuesta de error (404):**
```json
{
  "exito": false,
  "mensaje": "Endpoint no encontrado"
}
```

## 🚀 Requisitos

- PHP 7.0 o superior

## 🎯 Características

- ✅ Retorna todos los TODOs
- ✅ CORS habilitado
- ✅ Respuestas en formato JSON
- ✅ Datos de ejemplo incluidos
- ✅ Manejo de preflight requests (OPTIONS)

## 📝 Datos de ejemplo

El backend viene con 4 TODOs de ejemplo:
1. Aprender PHP
2. Crear una API REST (completado)
3. Conectar frontend con backend
4. Deployar la aplicación

---

Para iniciar el servidor, ver el README principal.
