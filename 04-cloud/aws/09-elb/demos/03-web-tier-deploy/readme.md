# Demo

We're going to SSH into web1 and deploy the web front end using `Docker`. We're then going to browse directly to web1's public IP address and verify that the web front end is actually working. 

- SSH into `web1`
- Deploy the front end using Docker
- Browse to web1's public IP address

## Deploying the Web

Now, just so you're not taken by surprise, let's look at the Docker command we're going to run. You don't need to understand this in any detail, but there are a couple of things I want to point out. 

```bash
docker run -d -p 80:3000 -h web1 jaimesalas/todo-app-front:4
```

Let's go ahead and SSH into the `web1` instance and run this. 

- Connect to your instance

```bash
ssh -i "your_key" your_instance
```

Here we are on the `web1` instance, and the first thing we're going to do is spin up the Docker container for the web front end. So we're going to go ahead and enter the command for that. 

```bash
docker run -d -p 80:3000 -h web1 jaimesalas/todo-app-front:4
```

Let's go ahead and grab the instance's public IP address. We'll do a curl `ifconfig.me`.

```bash
curl ifconfig.me
```

Let's jump over to our browser and then paste the IP address into the address bar and hit Enter. 

> Copy public IP on browser

Now the front end of the web app is configured to display information about the client, web server, and application server. 

Open dev tools, the cookie information is also blank because we, the client, have not sent any cookie.

> Browse using `https://<your ip>`
