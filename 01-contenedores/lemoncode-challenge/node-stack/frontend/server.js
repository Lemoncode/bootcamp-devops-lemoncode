//Módulos
const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));
const 
    express = require('express'),
    app = express();
require('dotenv').config();

const LOCAL = process.env.API_URL || 'http://localhost:5000/api/classes';
const PORT = 3000;
const APP_URL = `http://localhost:${PORT}`;

app.set('view engine', 'ejs');

// Middleware para logging mejorado
app.use((req, res, next) => {
    const timestamp = new Date().toLocaleTimeString('es-ES');
    console.log(`📍 [${timestamp}] ${req.method} ${req.path}`);
    next();
});

app.get('/', async (req, res) => {
    try {
        //Recuperar clases de la API
        const apiUrl = process.env.API_URL || LOCAL;
        console.log(`🔄 Conectando a la API: ${apiUrl}`);
        
        const response = await fetch(apiUrl);
        const classes = await response.json();
        
        console.log(`✅ ${classes.length} clases cargadas correctamente`);
        res.render('index', { classes });
    } catch (error) {
        console.error(`❌ Error al conectar con la API: ${error.message}`);
        res.status(500).render('index', { classes: [] });
    }
});

const server = app.listen(PORT, () => {
    const apiUrl = process.env.API_URL || LOCAL;
    console.log('\n' + '='.repeat(70));
    console.log('🍋 LEMONCODE CALENDAR - FRONTEND SERVER');
    console.log('='.repeat(70));
    console.log(`🚀 Servidor iniciado correctamente`);
    console.log(`📱 Web: \x1b]8;;${APP_URL}\x1b\\${APP_URL}\x1b]8;;\x1b\\`);
    console.log(`🔗 API: ${apiUrl}`);
    console.log(`⏰ Hora: ${new Date().toLocaleString('es-ES')}`);
    console.log('='.repeat(70) + '\n');
});

server.on('error', (error) => {
    console.error(`❌ Error en el servidor: ${error.message}`);
    process.exit(1);
});