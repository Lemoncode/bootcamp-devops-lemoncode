En este ejemplo tenemos dos aplicaciones que comparten varias instrucciones/capas de sus Dockerfile, lo cual optimiza el tamaño de las imágenes y el tiempo de construcción.

## Comprobar qué capas se comparten

Puedes usar el comando `docker image inspect` para ver las capas de cada imagen y comprobar cuáles se comparten.

```bash
docker image inspect 0gis0/frontend --format='{{json .RootFS.Layers}}' | jq
docker image inspect 0gis0/backend --format='{{json .RootFS.Layers}}' | jq
```

Con jq puedes formatear la salida para que sea más legible y también que de solo las capas que son iguales entre ambas imágenes:

```bash
docker image inspect 0gis0/frontend --format='{{json .RootFS.Layers}}' | jq '.[ ]' > frontend_layers.txt
docker image inspect 0gis0/backend --format='{{json .RootFS.Layers}}' | jq '.[ ]' > backend_layers.txt
comm -12 <(sort frontend_layers.txt) <(sort backend_layers.txt)
```