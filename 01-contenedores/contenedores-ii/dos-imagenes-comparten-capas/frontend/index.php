<?php
// Frontend en PHP que consume la API del backend

// Configuración
// Escenario deseado: Frontend expuesto en puerto 8000 y Backend en puerto 8001
// Ambos pueden estar fuera de la misma red interna de Docker, así que el frontend
// debe acceder al backend usando el host (máquina) y no el nombre del contenedor.

// Valor por defecto (asumiendo ejecución en Docker con acceso al host):
$api_url = 'http://host.docker.internal:8001/api.php';

$todos = [];
$error = null;

// Obtener los TODOs desde la API
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    try {
        $response = @file_get_contents($api_url);
        if ($response === false) {
            $error = 'No se pudo conectar a la API del backend';
        } else {
            $data = json_decode($response, true);
            if ($data && $data['exito']) {
                $todos = $data['datos'];
            } else {
                $error = $data['mensaje'] ?? 'Error al obtener los TODOs';
            }
        }
    } catch (Exception $e) {
        $error = 'Error: ' . $e->getMessage();
    }
}

// Calcular estadísticas
$total = count($todos);
$completados = count(array_filter($todos, function($t) { return $t['completado']; }));
$pendientes = $total - $completados;

// Función helper para formatear fecha
function formatear_fecha($fecha_str) {
    $fecha = DateTime::createFromFormat('Y-m-d', $fecha_str);
    if ($fecha) {
        setlocale(LC_TIME, 'es_ES.UTF-8');
        return strftime('%d de %B de %Y', $fecha->getTimestamp());
    }
    return $fecha_str;
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mi App de TODOs</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>📝 Mi Lista de TODOs</h1>
            <p class="subtitle">Una aplicación simple de tareas</p>
        </header>

        <main>
            <?php if ($error): ?>
                <div class="error">
                    <p>❌ <?php echo htmlspecialchars($error); ?></p>
                </div>
            <?php endif; ?>

            <?php if (!$error && count($todos) >= 0): ?>
                <section class="stats">
                    <div class="stat-box">
                        <span class="stat-number"><?php echo $total; ?></span>
                        <span class="stat-label">Total de tareas</span>
                    </div>
                    <div class="stat-box">
                        <span class="stat-number"><?php echo $completados; ?></span>
                        <span class="stat-label">Completadas</span>
                    </div>
                    <div class="stat-box">
                        <span class="stat-number"><?php echo $pendientes; ?></span>
                        <span class="stat-label">Pendientes</span>
                    </div>
                </section>

                <section class="todos-section">
                    <h2>Tareas</h2>
                    <?php if (count($todos) > 0): ?>
                        <ul class="todos-list">
                            <?php foreach ($todos as $todo): ?>
                                <li class="todo-item <?php echo $todo['completado'] ? 'completed' : ''; ?>">
                                    <input 
                                        type="checkbox" 
                                        class="todo-checkbox" 
                                        <?php echo $todo['completado'] ? 'checked' : ''; ?> 
                                        disabled
                                    >
                                    <div class="todo-content">
                                        <div class="todo-title"><?php echo htmlspecialchars($todo['titulo']); ?></div>
                                        <div class="todo-date">
                                            📅 <?php echo formatear_fecha($todo['fecha']); ?>
                                        </div>
                                    </div>
                                </li>
                            <?php endforeach; ?>
                        </ul>
                    <?php else: ?>
                        <div class="todo-item">
                            <p>No hay tareas aún 🎉</p>
                        </div>
                    <?php endif; ?>
                </section>
            <?php endif; ?>

            <form method="GET" style="margin-top: 20px;">
                <button type="submit" class="refresh-btn">🔄 Actualizar</button>
            </form>
        </main>

        <footer>
            <p>API Backend: <span id="apiUrl"><?php echo htmlspecialchars($api_url); ?></span></p>
            <p style="margin-top: 5px; font-size: 0.85em;">Renderizado en servidor con PHP</p>
        </footer>
    </div>
</body>
</html>
