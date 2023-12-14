# Demo

Connect via SSH to db instance

```bash
ssh -i "your_key" ec2-user@<public_dns>
```

Install Docker

```bash
sudo dnf update
sudo dnf install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER 
newgrp docker
```


Run Mongo

```bash
docker run -d -p 27017:27017 \
  -e MONGO_INITDB_DATABASE=tododb \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=password \
  mongo:7
```

Connect to an app tier instance, for example `app1`

Ping to db instance

```bash
nslookup ip-172-31-101-99.eu-west-3.compute.internal
```

```
Server:         172.31.0.2
Address:        172.31.0.2#53

Non-authoritative answer:
Name:   ip-172-31-101-99.eu-west-3.compute.internal
Address: 172.31.101.99
```

Check Mongo connectivity. Test Mongo connectivity. From EC2 Dashboard, we can check the internal IP and DNS

- ip-172-31-101-99.eu-west-3.compute.internal
- 172.31.101.99

```bash
sudo dnf -y install telnet
telnet ip-172-31-101-99.eu-west-3.compute.internal 27017
```

```bash
docker run -d -p 8080:3000 \
  -e MONGODB_URI=mongodb://admin:password@ip-172-31-101-99.eu-west-3.compute.internal:27017/tododb?authSource=admin \
  jaimesalas/todo-app-api:4
```

Connect to `app2` and `app3` and follow the same process.