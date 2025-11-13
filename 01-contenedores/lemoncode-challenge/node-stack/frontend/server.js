require('dotenv').config();

const express = require('express');
const axios = require('axios');
const path = require('path');

const app = express();

// ============================================
// CONFIGURACIÓN
// ============================================
const PORT = process.env.PORT || 3000;
const API_URL = process.env.API_URL || 'http://localhost:5001';
const HOST = process.env.HOST || '0.0.0.0';

// ============================================
// MIDDLEWARES
// ============================================
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(express.static(path.join(__dirname, 'public')));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ============================================
// UTILIDADES - LLAMADAS A LA API
// ============================================
async function getTopics() {
  try {
    const response = await axios.get(`${API_URL}/api/topics`);
    return response.data;
  } catch (error) {
    console.error('Error al obtener topics:', error.message);
    return [];
  }
}

async function getTopic(id) {
  try {
    const response = await axios.get(`${API_URL}/api/topics/${id}`);
    return response.data;
  } catch (error) {
    console.error('Error al obtener topic:', error.message);
    return null;
  }
}

async function createTopic(data) {
  try {
    const response = await axios.post(`${API_URL}/api/topics`, data);
    return response.data;
  } catch (error) {
    console.error('Error al crear topic:', error.message);
    throw error;
  }
}

async function updateTopic(id, data) {
  try {
    const response = await axios.put(`${API_URL}/api/topics/${id}`, data);
    return response.data;
  } catch (error) {
    console.error('Error al actualizar topic:', error.message);
    throw error;
  }
}

async function deleteTopic(id) {
  try {
    await axios.delete(`${API_URL}/api/topics/${id}`);
    return true;
  } catch (error) {
    console.error('Error al eliminar topic:', error.message);
    throw error;
  }
}

// ============================================
// RUTAS - VISTAS
// ============================================

// Página principal - Lista de topics
app.get('/', async (req, res) => {
  try {
    const topics = await getTopics();
    res.render('index', { topics, message: req.query.message });
  } catch (error) {
    res.status(500).render('error', { error: 'Error al cargar los topics' });
  }
});

// Página para crear nuevo topic
app.get('/create', (req, res) => {
  res.render('create');
});

// Procesar formulario de creación
app.post('/create', async (req, res) => {
  try {
    const { name, description } = req.body;
    
    if (!name || !description) {
      return res.render('create', { error: 'El nombre y descripción son obligatorios' });
    }

    await createTopic({ name, description });
    res.redirect('/?message=Topic creado exitosamente');
  } catch (error) {
    res.render('create', { error: 'Error al crear el topic' });
  }
});

// Página para editar topic
app.get('/edit/:id', async (req, res) => {
  try {
    const topic = await getTopic(req.params.id);
    if (!topic) {
      return res.status(404).render('error', { error: 'Topic no encontrado' });
    }
    res.render('edit', { topic });
  } catch (error) {
    res.status(500).render('error', { error: 'Error al cargar el topic' });
  }
});

// Procesar formulario de edición
app.post('/edit/:id', async (req, res) => {
  try {\n    const { name, description } = req.body;
    
    if (!name || !description) {
      const topic = await getTopic(req.params.id);
      return res.render('edit', { topic, error: 'El nombre y descripción son obligatorios' });
    }

    await updateTopic(req.params.id, { name, description });
    res.redirect('/?message=Topic actualizado exitosamente');
  } catch (error) {
    res.status(500).render('error', { error: 'Error al actualizar el topic' });
  }
});

// Eliminar topic
app.post('/delete/:id', async (req, res) => {
  try {
    await deleteTopic(req.params.id);
    res.redirect('/?message=Topic eliminado exitosamente');
  } catch (error) {
    res.status(500).render('error', { error: 'Error al eliminar el topic' });
  }
});

// ============================================
// MANEJO DE ERRORES
// ============================================
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).render('error', { error: 'Algo salió mal' });
});

app.use((req, res) => {
  res.status(404).render('error', { error: 'Página no encontrada' });
});

// ============================================
// INICIO DEL SERVIDOR
// ============================================
app.listen(PORT, HOST, () => {
  console.log(`🌐 Frontend ejecutándose en http://${HOST}:${PORT}`);
  console.log(`📡 Conectando a API en ${API_URL}`);
});