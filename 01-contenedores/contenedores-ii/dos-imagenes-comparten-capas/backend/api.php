<?php
// Habilitar CORS para que el frontend pueda acceder al backend
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json; charset=utf-8');

// Manejo de preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Datos de ejemplo
$todos = [
    [
        'id' => 1,
        'titulo' => 'Aprender PHP',
        'completado' => false,
        'fecha' => '2025-10-23'
    ],
    [
        'id' => 2,
        'titulo' => 'Crear una API REST',
        'completado' => true,
        'fecha' => '2025-10-22'
    ],
    [
        'id' => 3,
        'titulo' => 'Conectar frontend con backend',
        'completado' => false,
        'fecha' => '2025-10-24'
    ],
    [
        'id' => 4,
        'titulo' => 'Deployar la aplicación',
        'completado' => false,
        'fecha' => '2025-10-25'
    ]
];

// Obtener la ruta solicitada
$metodo = $_SERVER['REQUEST_METHOD'];
$ruta = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// Limpiar la ruta de posibles prefijos
$ruta = str_replace('/backend/api.php', '', $ruta);
$ruta = str_replace('/api.php', '', $ruta);

// Endpoint: GET / - Obtener todos los todos
if ($metodo === 'GET' && ($ruta === '' || $ruta === '/')) {
    http_response_code(200);
    echo json_encode([
        'exito' => true,
        'mensaje' => 'Todos obtenidos correctamente',
        'datos' => $todos,
        'cantidad' => count($todos)
    ]);
    exit();
}

// Si no coincide con ninguna ruta
http_response_code(404);
echo json_encode([
    'exito' => false,
    'mensaje' => 'Endpoint no encontrado'
]);
?>
