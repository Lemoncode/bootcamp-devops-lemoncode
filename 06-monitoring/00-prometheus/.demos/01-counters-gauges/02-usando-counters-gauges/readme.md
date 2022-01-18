## Setup

Una máquina Linux con Docker instalado


```Vagrantfile
Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.network "private_network", ip: "10.0.0.10"
  config.vm.provision "docker"
end
```

> Esta máquina será accesible desde el `host` en la dirección `10.0.0.10` 

Para arrancar la VM

```bash
vagrant up
```

Para acceder a la VM

```bash
vagrant ssh
```

## 1. Proceso Batch

Vamos a utilizar la app que hemos generado en las demos anteriores.

```bash
docker run -d --name batch \
 -e PORT="8080" \
 -p 8080:8080 \
 jaimesalas/prom-batch

docker logs batch
```

> Navegar a http://10.0.0.10:8080/metrics

### Custom application metrics

- `worker_jobs_active` es un _Gauge_, cuando refrescamos podemos ver como el valor sube y baja
- `worker_jobs_total` es un _Counter_, los números siempre aumentan, el `counter` también tiene etiquetas para registrar las variaciones. 

### Node metrics

- `nodejs_heap_size_used_bytes` - El tamaño de heap usado por el proceso de Node.js.  
- `process_cpu_seconds_total` - Tiempo total de CPU gastado por el sistema y el usuario.

## 2. - Node Exporter

Descargar y extraer [Node Exporter](https://github.com/prometheus/node_exporter): 

```
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz

tar xvfz node_exporter-1.3.1.linux-amd64.tar.gz

cd node_exporter-1.3.1.linux-amd64/
```

Ejecutar (normalmente será un daemon):

```
./node_exporter
```

> Browse to http://10.0.0.10:9100/metrics

###  Hay métricas de hardware/OS

- `node_disk_io_time_seconds_total` - es un contador con la etiqueta `name`
- `node_cpu_seconds_total` - tiene etiquetas para el CPU core y el modo de trabajo
- `node_filesystem_avail_bytes` - es un gauge con el espacio en disco libre

### Y métricas de mera información

- `node_uname_info` - devuelve texto que da información de la version

## Referencias

[What is memory heap?](https://stackoverflow.com/questions/2308751/what-is-a-memory-heap)
[Memory management](https://en.wikipedia.org/wiki/Memory_management#HEAP)