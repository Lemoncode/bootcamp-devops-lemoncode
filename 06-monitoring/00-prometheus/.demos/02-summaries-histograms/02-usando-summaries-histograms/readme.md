## Setup

```Vagrantfile
$script = <<-SCRIPT
echo Downloading prometheus node exporter linux

apt-get update
apt-get -y install prometheus-node-exporter

SCRIPT

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.network "private_network", ip: "10.0.0.10"
  config.vm.provision "docker"
  config.vm.provision "shell", inline: $script
end
```

> Node exporter ya está instalado pero necesiatamos invocarlo manualmente.

> Está máquina es accesible desde el `host` en la IP `10.0.0.10`

Arrancamos la máquina de la siguiente forma:

```bash
vagrant up
```

Para entrar en la máquina:

```bash
vagrant ssh
```

## 1. Web Application

Arrancamos la aplicación web que utilizaba la librería cliente de `Prometheus` para generar las métricas.

```bash
docker run -d --name web \
 -e PORT="8080" \
 -p 8080:8080 \
 jaimesalas/prom-web

docker logs web
```

Vamos a realizar un par de peticiones

```bash
curl http://10.0.0.10:8080/quote
curl -X GET "http://10.0.0.10:8080/quote?slow=true"
```

> Navegar a: http://10.0.0.10:8080/metrics

### Podemos encontrar las siguientes métricas

- `http_requests_received_total` - es un `counter` con las etiquetas para el método HTTP y el código de la respuesta
- `http_request_duration_seconds` - es un `histogram` con la duración del procesado de peticiones por segundo
- - `web_delay_seconds` - es un `summary` del retardo añadido a la respuesta

Si navegamos a http://10.0.0.10:9100/metrics estamos accediendo a las métricas expuestas por el Node Exporter.

