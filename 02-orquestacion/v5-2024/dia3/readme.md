# Dia 3: Deployments y configuración de contenedores

Introdujimos los deployments (para gestionar actualizaciones de replicasets) así como los ConfigMaps y los Secrets para pasar configuraciones (incluyendo ficheros) a los contenedores.

Vimos el volumen emptyDir que permite compartir un diretorio entre los contenedores de un pod y así pasarse información entre ellos.

> Recordad que los contenedores dentro de un mismo pod comparten espacio de red (se comunican usando localhost) pero también otros mecanismos IPC (pipes y memorias compartidas). Los volúmenes emptyDir completan esta serie de mecnaimsos, dando un espacio de sistema de ficheros compartido. De este modo p.ej. un contenedor puede generar un fichero que puede ser leído por otro.