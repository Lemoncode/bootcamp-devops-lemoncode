# Topics Manager - Backend API

## 📡 Endpoints Implementados

### 1. GET `/api/topics`
Obtiene la lista de todos los topics.

**Respuesta exitosa (200):**
```json
[
  {
    "id": "507f1f77bcf86cd799439011",
    "name": "React Basics"
  },
  {
    "id": "507f1f77bcf86cd799439012",
    "name": "TypeScript Advanced"
  }
]
```

**Uso:**
```typescript
fetch("http://localhost:8080/api/topics")
  .then(res => res.json())
  .then(topics => console.log(topics))
```

---

### 2. POST `/api/topics`
Crea un nuevo topic.

**Parámetros (JSON):**
```json
{
  "name": "New Topic Name"
}
```

**Respuesta exitosa (200):**
```json
{
  "_id": "507f1f77bcf86cd799439013",
  "name": "New Topic Name",
  "__v": 0
}
```

**Uso:**
```typescript
fetch("http://localhost:8080/api/topics", {
  method: "POST",
  headers: {
    "Content-Type": "application/json"
  },
  body: JSON.stringify({ name: "New Topic" })
})
.then(res => res.json())
.then(result => console.log(result))
```

---

### 3. DELETE `/api/topics/:id` ✅ NUEVA
Elimina un topic específico por su ID.

**Parámetros:**
- `id` (URL parameter): ID de MongoDB del topic

**Respuesta exitosa (200):**
```json
{
  "message": "Topic deleted successfully",
  "id": "507f1f77bcf86cd799439011"
}
```

**Respuesta error - no encontrado (404):**
```json
{
  "error": "Topic not found"
}
```

**Respuesta error - validación (400):**
```json
{
  "error": "Invalid topic ID"
}
```

**Uso:**
```typescript
fetch("http://localhost:8080/api/topics/507f1f77bcf86cd799439011", {
  method: "DELETE"
})
.then(res => res.json())
.then(result => console.log(result))
```

---

## 🔧 Características de Seguridad

✅ **Validación de ID**: Usa `findByIdAndDelete` que valida automáticamente IDs de MongoDB
✅ **Manejo de errores**: Retorna errores apropiadios (404 si no existe, 400 para validación)
✅ **Logging**: Logs en consola para debugging
✅ **CORS**: Habilitado para todas las rutas

---

## 📊 Código Implementado

### Backend (`index.js`)
```javascript
router.delete("/topics/:id", async (req, res) => {
  console.log("[DELETE] Topic by ID:", req.params.id);

  try {
    const result = await Topic.findByIdAndDelete(req.params.id);
    if (!result) {
      return res.status(404).send({ error: "Topic not found" });
    }
    console.log("Deleted topic:", result);
    res.send({ message: "Topic deleted successfully", id: req.params.id });
  } catch (error) {
    console.error(error);
    res.status(400).send({ error: error.message });
  }
});
```

### Frontend (`topic-table.tsx`)
```typescript
const handleDeleteTopic = async (id: string) => {
  if (!window.confirm("Are you sure you want to delete this topic?")) {
    return;
  }

  try {
    const response = await fetch(`http://localhost:8080/api/topics/${id}`, {
      method: "DELETE",
    });

    if (!response.ok) {
      throw new Error("Failed to delete topic");
    }

    await fetchTopics();
  } catch (error) {
    console.error("Error deleting topic:", error);
    setError("Failed to delete topic. Please try again.");
  }
};
```

---

## 🎯 Flujo de Uso

1. **Usuario hace click en "Delete"** en el botón de la tarjeta de topic
2. **Se muestra confirmación** con `window.confirm()`
3. **Se envía DELETE request** a `/api/topics/:id`
4. **Backend elimina el topic** de la base de datos
5. **Frontend recarga la lista** y muestra el resultado

---

## ✨ Mejoras Futuras

- [ ] Soft delete (marcar como eliminado sin borrar)
- [ ] Historial de eliminaciones
- [ ] Recuperación de topics eliminados
- [ ] Batch delete (eliminar múltiples)
- [ ] Confirmación adicional con email
