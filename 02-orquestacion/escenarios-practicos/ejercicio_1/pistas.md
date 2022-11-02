# Pistas

# 1.1 Que arranque el pod

El pod entra en `ImgPullBackoff` que significa que no encuentra la imagen. Quizá mirar la página de DockerHub de la imagen te pueda ayudar... https://hub.docker.com/r/lemoncodersbc/go-hello-world

## 1.2 Réplicas

Recuerdas como crear réplicas de un pod? No te basta solo con el pod... Prueba a crear un `ReplicaSet` o mejor aún un `Deployment` en su lugar!