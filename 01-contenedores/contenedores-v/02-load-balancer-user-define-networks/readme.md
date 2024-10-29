## Load Balancer

### Code

```bash
npm init -y
```

```bash
npm install express
```

Crear `index.js`

```js
const express = require('express');

const PORT = 8080;

const app = express();

app.get('/', (req, res) => {
    console.log(req.headers);
    const instance = (process.env.INSTANCE) ? process.env.INSTANCE : 'no instance feed';
    res.send(`Hello world from ${instance}\n`);
});

app.listen(PORT);

console.log(`Running on port: ${PORT}`);
```

Editar `package.json`

```diff
{
  "name": "01_load_balancer_user_define_networks",
  "version": "1.0.0",
  "description": "### Code",
  "main": "index.js",
  "scripts": {
+   "start": "node .",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "express": "^4.17.1"
  }
}

```

Crear el `Dockerfile` para la aplicación de `node`

```Dockerfile
FROM node:alpine

WORKDIR /opt/app

COPY index.js .
COPY package.json .

RUN npm install --only=production

EXPOSE 8080

CMD [ "npm", "start" ]
```


Ahora vamos a crear el código del balanceador de carga

Crear `nginx/nginx.conf`

```nginx.conf
user root;
error_log /var/log/nginx/error.log;
pid /var/run/nginx.pid;
events {
    worker_connections 1024;
    use epoll;
}
http {
    upstream nodeapp {
        server myapp1:8080;
        server myapp2:8080;
        server myapp3:8080;
    }
    server {
        server_name localhost;
        listen 80;
        error_log  /var/log/nginx/errorhttp.log;
        access_log /var/log/nginx/accesshttp.log;
        location / {
            proxy_pass http://nodeapp;
        }
    }
}
```

Crear `nginx/Dockerfile`

```Dockerfile
FROM nginx

ADD ./nginx.conf /etc/nginx
```

Primero creamos una nueva red.

```bash
docker network create --driver=bridge \
--subnet=172.100.1.0/24 --gateway=172.100.1.1 \
--ip-range=172.100.1.2/25 mybridge
```

Generamos una nueva build de myapp

```bash
docker build -t myapp .
```

Ahora vamos a ejecutar múltiples contenedores en la _network_

```bash
docker run -d --rm --net=mybridge -e INSTANCE=myapp1 --name myapp1 myapp
docker run -d --rm --net=mybridge -e INSTANCE=myapp2 --name myapp2 myapp
docker run -d --rm --net=mybridge -e INSTANCE=myapp3 --name myapp3 myapp
```

Si inspeccionamos la red `mybridge`

```bash
docker network inspect mybridge
...
"Containers": {
            "1981383f2b468348cbb0430f61e9603f2601bf9140c8394c27b6774130a4eb8e": {
                "Name": "myapp1",
                "EndpointID": "9a9da87bf1d261f7685108dba565a2f36eff14cab66a2c08c0376a46ade33ba8",
                "MacAddress": "02:42:ac:64:01:02",
                "IPv4Address": "172.100.1.2/24",
                "IPv6Address": ""
            },
            "aee2591917905359c6a799ee66537e67561f133986512854a5715adb53e4e018": {
                "Name": "myapp2",
                "EndpointID": "6df1ce35a2c6381bb408fd25e644bac27bcd6a73c43a32c0bf8cbc3f27f39479",
                "MacAddress": "02:42:ac:64:01:03",
                "IPv4Address": "172.100.1.3/24",
                "IPv6Address": ""
            },
            "b6eb7b3c96a99f999b4ecc2f73e2c45ef383de5a202051fbdbe1d5bd81fe0039": {
                "Name": "myapp3",
                "EndpointID": "9eae97b378e7e7b8c1e0866f2654aa2eb768303e6313e4edb431043a11d25b20",
                "MacAddress": "02:42:ac:64:01:04",
                "IPv4Address": "172.100.1.4/24",
                "IPv6Address": ""
            }
        }
```

Creamos la imagen del load balancer, desde el directorio `nginx`

```bash
docker build -t myloadbalancer .
```

Ahora podemos ejecutar el `load balancer` en la misma `network` y mapeando al puerto 80.

```bash
docker run -d --rm --net=mybridge -p 80:80 \
--name mylb myloadbalancer
```

Si volvemos a inspeccionar la red deberíamos de ver el contenedor `mylb`

```bash
docker network inspect mybridge
```

```bash
[
    {
        "Name": "mybridge",
        "Id": "bc3de4a5c836c2628ce88e62f93118fa1903ef93af6ae42df20b124ee353c1ec",
        "Created": "2020-06-07T17:14:25.9972015Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.100.1.0/24",
                    "IPRange": "172.100.1.2/25",
                    "Gateway": "172.100.1.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "022757e965b3039d59b494719a40f5fc0f4e57c24e89a17bdb8a7cb5daa7c86a": {
                "Name": "myapp3",
                "EndpointID": "a70accbd908292233e1456c26cd613c15d294bb5926bb0225452cf5da4de171b",
                "MacAddress": "02:42:ac:64:01:04",
                "IPv4Address": "172.100.1.4/24",
                "IPv6Address": ""
            },
            "4ab26c238bf61aa95c070505242d19e390343dd5df2223d3b551bf2c33ef4de0": {
                "Name": "myapp1",
                "EndpointID": "86a6e9471670e09ecb13c37841bb70544494bb6ce21de7d23b408229538d1a7b",
                "MacAddress": "02:42:ac:64:01:02",
                "IPv4Address": "172.100.1.2/24",
                "IPv6Address": ""
            },
            "4c2bfeda34550a2377ed466176b25c35d64186576a7fa0b5612ab6ce1b99c375": {
                "Name": "myapp2",
                "EndpointID": "12f9b535f80531cf311f76ece9c66d7af4056f5078de4a7c925d834a106ab738",
                "MacAddress": "02:42:ac:64:01:03",
                "IPv4Address": "172.100.1.3/24",
                "IPv6Address": ""
            },
            "d9144e3be43f22a230fc28b4f3a1467b3224aa4371167a8efb9339dc67492bb8": {
                "Name": "mylb",
                "EndpointID": "40e899536990a7b48b5b1cc86211f6316432b271bbb357ecf11de5bf4fc0561e",
                "MacAddress": "02:42:ac:64:01:05",
                "IPv4Address": "172.100.1.5/24",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {}
    }
]
```

Podemos comprobar que ahora existe `service discovery` dentro de la `network`

```bash
docker exec mylb cat /etc/resolv.conf
nameserver 127.0.0.11
options ndots:0
```

```bash
docker run --rm --net=mybridge busybox:1.28 ping -c 4 myapp1
```

La salida será similar a esta:

```
PING myapp1 (172.100.1.2): 56 data bytes
64 bytes from 172.100.1.2: seq=0 ttl=64 time=0.291 ms
64 bytes from 172.100.1.2: seq=1 ttl=64 time=0.099 ms
64 bytes from 172.100.1.2: seq=2 ttl=64 time=0.115 ms
64 bytes from 172.100.1.2: seq=3 ttl=64 time=0.148 ms

--- myapp1 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 0.099/0.163/0.291 ms
```

```bash
docker run --rm --net=mybridge busybox:1.28 nslookup myapp1
```

```
Server:    127.0.0.11
Address 1: 127.0.0.11

Name:      myapp1
Address 1: 172.100.1.2 myapp1.mybridge
```
