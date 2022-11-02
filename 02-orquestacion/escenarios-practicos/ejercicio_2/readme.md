# Ejercicio 2: No puedo acceder!

El equipo de backend ha desplegado su pod replicado, pero parece que otros equipos se quejan que el pod no responde.

El equipo de backend afirma que su servicio debería responder en http://backend pero parece ser que no es así

¿Qué está ocurriendo?

## 2.1 Haz los pods accesibles

Asegúrate que se puede acceder al pod desde dentro del clúster. Para probarlo crea un pod de busybox y enlázate a él para desde el shell de busybox ejecutar un `wget -qO- http://backend` y obtener la respuesta.

# 2.2 Ofrece acceso desde el exterior

El equipo de frontend al final decide hacer una SPA, lo que implica que las llamadas al backend las realizará un navegdor. Por ello no basta que el backend sea accesible, debe serlo desde fuera del cluster. ¿Como harías el backend accesible desde un DNS?