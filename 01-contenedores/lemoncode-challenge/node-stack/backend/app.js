require('dotenv').config();

const express = require('express');
const cors = require('cors');
const { MongoClient, ObjectId } = require('mongodb');

const app = express();

// ============================================
// CONFIGURACIÓN
// ============================================
const DB_URL = process.env.DATABASE_URL || 'mongodb://localhost:27017';
const DB_NAME = process.env.DATABASE_NAME || 'TopicstoreDb';
const HOST = process.env.HOST || '0.0.0.0';
const PORT = 5001;

let db;
let topicsCollection;
let mongoClient;

// ============================================
// MIDDLEWARES
// ============================================
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

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
    topicsCollection = db.collection('Topics');
    console.log('📋 Colección Topics cargada');
  } catch (error) {
    console.error('❌ Error al conectar a MongoDB:', error.message);
    process.exit(1);
  }
}

// ============================================
// RUTAS - TOPICS
// ============================================

// GET /api/topics - Obtener todos los tópicos
app.get('/api/topics', async (req, res) => {
  try {
    console.log('📥 GET /api/topics');
    const topics = await topicsCollection.find({}).toArray();
    console.log(`✅ Se obtuvieron ${topics.length} tópicos`);
    res.json(topics);
  } catch (error) {
    console.error('❌ Error al obtener tópicos:', error.message);
    res.status(500).json({ error: 'Error al obtener tópicos' });
  }
});

// GET /api/topics/:id - Obtener un tópico por ID
app.get('/api/topics/:id', async (req, res) => {
  try {
    const { id } = req.params;
    console.log(`📥 GET /api/topics/${id}`);

    if (!ObjectId.isValid(id)) {
      return res.status(400).json({ error: 'ID inválido' });
    }

    const topic = await topicsCollection.findOne({ _id: new ObjectId(id) });
    if (!topic) {
      return res.status(404).json({ error: 'Tópico no encontrado' });
    }

    console.log(`✅ Tópico ${id} obtenido`);
    res.json(topic);
  } catch (error) {
    console.error('❌ Error al obtener tópico:', error.message);
    res.status(500).json({ error: 'Error al obtener tópico' });
  }
});

// POST /api/topics - Crear un nuevo tópico
app.post('/api/topics', async (req, res) => {
  try {
    const topic = req.body;
    console.log(`📥 POST /api/topics - ${JSON.stringify(topic)}`);

    if (!topic.Name) {
      return res.status(400).json({ error: 'El campo Name es requerido' });
    }

    const result = await topicsCollection.insertOne(topic);
    const createdTopic = { _id: result.insertedId, ...topic };
    console.log(`✅ Tópico creado: ${topic.Name}`);
    res.status(201).json(createdTopic);
  } catch (error) {
    console.error('❌ Error al crear tópico:', error.message);
    res.status(500).json({ error: 'Error al crear tópico' });
  }
});

// PUT /api/topics/:id - Actualizar un tópico
app.put('/api/topics/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const topic = req.body;
    console.log(`📥 PUT /api/topics/${id} - ${JSON.stringify(topic)}`);

    if (!ObjectId.isValid(id)) {
      return res.status(400).json({ error: 'ID inválido' });
    }

    const result = await topicsCollection.updateOne(
      { _id: new ObjectId(id) },
      { $set: topic }
    );

    if (result.matchedCount === 0) {
      return res.status(404).json({ error: 'Tópico no encontrado' });
    }

    console.log(`✅ Tópico ${id} actualizado`);
    res.json({ _id: id, ...topic });
  } catch (error) {
    console.error('❌ Error al actualizar tópico:', error.message);
    res.status(500).json({ error: 'Error al actualizar tópico' });
  }
});

// DELETE /api/topics/:id - Eliminar un tópico
app.delete('/api/topics/:id', async (req, res) => {
  try {
    const { id } = req.params;
    console.log(`📥 DELETE /api/topics/${id}`);

    if (!ObjectId.isValid(id)) {
      return res.status(400).json({ error: 'ID inválido' });
    }

    const result = await topicsCollection.deleteOne({ _id: new ObjectId(id) });

    if (result.deletedCount === 0) {
      return res.status(404).json({ error: 'Tópico no encontrado' });
    }

    console.log(`✅ Tópico ${id} eliminado`);
    res.status(204).send();
  } catch (error) {
    console.error('❌ Error al eliminar tópico:', error.message);
    res.status(500).json({ error: 'Error al eliminar tópico' });
  }
});

// ============================================
// INICIAR SERVIDOR
// ============================================
async function startServer() {
  try {
    console.log('\n🔧 Inicializando backend...');
    await connectDB();

    app.listen(PORT, HOST, () => {
      const url = `http://${HOST === '0.0.0.0' ? 'localhost' : HOST}:${PORT}`;
      console.log('');
      console.log('═══════════════════════════════════════════════════════════════');
      console.log(`🚀 Servidor ejecutándose en: ${url}/api/topics`);
      console.log('═══════════════════════════════════════════════════════════════');
      console.log('');
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
