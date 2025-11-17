require('dotenv').config();

const express = require('express');
const cors = require('cors');
const { MongoClient, ObjectId } = require('mongodb');

const app = express();

// ============================================
// CONFIGURACIÓN
// ============================================
const DB_URL = process.env.DATABASE_URL || 'mongodb://localhost:27017';
const DB_NAME = process.env.DATABASE_NAME || 'ClassesDb';
const HOST = process.env.HOST || '0.0.0.0';
const PORT = process.env.PORT || 5000;

let db;
let classesCollection;
let mongoClient;

// ============================================
// MIDDLEWARES
// ============================================
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Middleware de logging
app.use((req, res, next) => {
  const timestamp = new Date().toLocaleTimeString('es-ES');
  console.log(`📍 [${timestamp}] ${req.method} ${req.path}`);
  next();
});

// ============================================
// CONEXIÓN A MONGODB
// ============================================
async function connectDB() {
  try {
    console.log('🔄 Conectando a MongoDB...');
    mongoClient = new MongoClient(DB_URL);
    await mongoClient.connect();
    console.log('✅ Conexión a MongoDB exitosa');

    db = mongoClient.db(DB_NAME);
    classesCollection = db.collection('Classes');
    console.log('📚 Colección Classes cargada');
  } catch (error) {
    console.error('❌ Error al conectar a MongoDB:', error.message);
    process.exit(1);
  }
}

// ============================================
// RUTAS - CLASSES
// ============================================

// GET /api/classes - Obtener todas las clases
app.get('/api/classes', async (req, res) => {
  try {
    const classes = await classesCollection.find({}).toArray();
    console.log(`✅ Se obtuvieron ${classes.length} clases`);
    res.json(classes);
  } catch (error) {
    console.error('❌ Error al obtener clases:', error.message);
    res.status(500).json({ error: 'Error al obtener clases' });
  }
});

// GET /api/classes/:id - Obtener una clase por ID
app.get('/api/classes/:id', async (req, res) => {
  try {
    const { id } = req.params;

    if (!ObjectId.isValid(id)) {
      return res.status(400).json({ error: 'ID inválido' });
    }

    const classItem = await classesCollection.findOne({ _id: new ObjectId(id) });
    if (!classItem) {
      return res.status(404).json({ error: 'Clase no encontrada' });
    }

    console.log(`✅ Clase ${id} obtenida`);
    res.json(classItem);
  } catch (error) {
    console.error('❌ Error al obtener clase:', error.message);
    res.status(500).json({ error: 'Error al obtener clase' });
  }
});

// POST /api/classes - Crear una nueva clase
app.post('/api/classes', async (req, res) => {
  try {
    const classItem = req.body;
    console.log(`📝 Creando clase: ${classItem.name}`);

    // Validación de campos requeridos
    if (!classItem.name || !classItem.instructor || !classItem.level) {
      return res.status(400).json({ 
        error: 'Los campos name, instructor y level son requeridos' 
      });
    }

    const result = await classesCollection.insertOne(classItem);
    const createdClass = { _id: result.insertedId, ...classItem };
    console.log(`✅ Clase creada: ${classItem.name}`);
    res.status(201).json(createdClass);
  } catch (error) {
    console.error('❌ Error al crear clase:', error.message);
    res.status(500).json({ error: 'Error al crear clase' });
  }
});

// PUT /api/classes/:id - Actualizar una clase
app.put('/api/classes/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const classItem = req.body;
    console.log(`📝 Actualizando clase ${id}`);

    if (!ObjectId.isValid(id)) {
      return res.status(400).json({ error: 'ID inválido' });
    }

    const result = await classesCollection.updateOne(
      { _id: new ObjectId(id) },
      { $set: classItem }
    );

    if (result.matchedCount === 0) {
      return res.status(404).json({ error: 'Clase no encontrada' });
    }

    console.log(`✅ Clase ${id} actualizada`);
    res.json({ _id: id, ...classItem });
  } catch (error) {
    console.error('❌ Error al actualizar clase:', error.message);
    res.status(500).json({ error: 'Error al actualizar clase' });
  }
});

// DELETE /api/classes/:id - Eliminar una clase
app.delete('/api/classes/:id', async (req, res) => {
  try {
    const { id } = req.params;
    console.log(`🗑️  Eliminando clase ${id}`);

    if (!ObjectId.isValid(id)) {
      return res.status(400).json({ error: 'ID inválido' });
    }

    const result = await classesCollection.deleteOne({ _id: new ObjectId(id) });

    if (result.deletedCount === 0) {
      return res.status(404).json({ error: 'Clase no encontrada' });
    }

    console.log(`✅ Clase ${id} eliminada`);
    res.status(204).send();
  } catch (error) {
    console.error('❌ Error al eliminar clase:', error.message);
    res.status(500).json({ error: 'Error al eliminar clase' });
  }
});

// ============================================
// INICIAR SERVIDOR
// ============================================
async function startServer() {
  try {
    console.log('\n' + '═'.repeat(70));
    console.log('🍋 LEMONCODE CALENDAR - BACKEND (Node.js + Express)');
    console.log('═'.repeat(70));
    await connectDB();

    app.listen(PORT, HOST, () => {
      const url = `http://${HOST === '0.0.0.0' ? 'localhost' : HOST}:${PORT}`;
      console.log(`🚀 Servidor ejecutándose en: ${url}`);
      console.log(`📚 API: ${url}/api/classes`);
      console.log(`⏰ Hora: ${new Date().toLocaleString('es-ES')}`);
      console.log('═'.repeat(70) + '\n');
    });
  } catch (error) {
    console.error('❌ Error al iniciar servidor:', error.message);
    process.exit(1);
  }
}

// Iniciar la aplicación
startServer();

// Manejo de cierre graceful
process.on('SIGTERM', async () => {
  console.log('\n🛑 Recibido SIGTERM, cerrando gracefully...');
  if (mongoClient) {
    await mongoClient.close();
    console.log('✅ Conexión a MongoDB cerrada');
  }
  process.exit(0);
});
