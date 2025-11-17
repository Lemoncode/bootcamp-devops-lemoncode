## Load Balancer

Contruimos nuestra aplicación:

```bash
cd server
```

```bash
docker build -t myapp .
```

Ahora podemos ejecutar nuestra aplicación:

```bash
docker run -d --rm -p 8080:8080 --name myapp myapp
```

We can make a simple load testing by

```bash
ab -n 1000 -c 100 http://localhost:8080/
```

```bash
Requests per second:    273.68 [#/sec] (mean)
Time per request:       365.390 [ms] (mean)
Time per request:       3.654 [ms] (mean, across all concurrent requests)
Transfer rate:          56.39 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    1   1.5      0       7
Processing:    55  354  67.9    339     492
Waiting:       33  288  68.4    284     459
Total:         55  354  67.6    339     492

Percentage of the requests served within a certain time (ms)
  50%    339
  66%    385
  75%    407
  80%    425
  90%    448
  95%    464
  98%    472
  99%    480
 100%    492 (longest request)
```

Para escalar el número de peticiones vamos a utilizar un balanceador de carga.

Create __load-balancer/nginx.conf__

```
user root;
error_log /var/log/nginx/error.log;
pid /var/run/nginx.pid;
events {
    worker_connections 1024;
    use epoll;
}
http {
    upstream nodeapp {
        server localhost:8081;
        server localhost:8082;
        server localhost:8088;
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

Create __load-balancer/Dockerfile__

```Dockerfile
FROM nginx

ADD ./nginx.conf /etc/nginx/
```

Create multiple instances

```bash
docker build -t myapp .
docker run -d --rm -p 8081:8080 myapp
docker run -d --rm -p 8082:8080 myapp
docker run -d --rm -p 8083:8080 myapp
```

We can check that the apps are up and running

```
curl http://localhost:8081
curl http://localhost:8082
curl http://localhost:8083
```

Now we can build our load balancer

```bash
cd load-balancer

docker build -t myloadbalancer .
```

And run the balancer as follows

```bash
docker run -d --net=host --name mylb myloadbalancer
```

Check the load balancer

```bash
curl http://localhost/
```

Let's do another load test

```bash
ab -n 1000 -c 100 http://localhost/
```

```bash
Requests per second:    2405.65 [#/sec] (mean)
Time per request:       41.569 [ms] (mean)
Time per request:       0.416 [ms] (mean*)

              min  mean[+/-sd] median   max
Connect:        0    0   0.4      0       2
Processing:     6   39  11.2     38      88
Waiting:        6   39  11.2     38      88
Total:          8   40  11.2     38      89

Percentage of the requests served within a certain time (ms)
  50%     38
  66%     43
  75%     45
  80%     46
  90%     53
  95%     65
  98%     70
  99%     75
 100%     89 (longest request)
```

## macos

- https://docs.docker.com/desktop/networking/#i-want-to-connect-from-a-container-to-a-service-on-the-host

Refactorizamos `load-balancer/nginx.conf`

```diff
http {
    upstream nodeapp {
-       server localhost:8081;
-       server localhost:8082;
-       server localhost:8088;
+       server host.docker.internal:8081;
+       server host.docker.internal:8082;
+       server host.docker.internal:8088;
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

```bash
docker kill mylb
```

```bash
docker rm mylb
```

```bash
cd load-balancer

docker build -t myloadbalancer .
```

```bash
docker run -d -p 80:80 --name mylb myloadbalancer
```

```bash
ab -n 1000 -c 100 http://localhost/
```