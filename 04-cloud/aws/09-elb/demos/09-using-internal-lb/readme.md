# Demo

We're going to reconfigure the web tier instances to point to the URL of the internal application load balancer, and here's how we're going to do it. 

First, we're going to destroy the existing Docker containers on `web1`, `web2`, and `web3`. Once we do that, we're going to recreate the containers using a command that looks something like this. 

```bash
docker run -d -p 80:3000 -e API_URL="http://<DNS API>:<PORT>" jaimesalas/todo-app-front:4
```

This is almost the same command we used when we initially deployed the web front end, but this time we're adding something new. The __‑e API_URL=__ parameter followed by the internal load balancer's URL tells the web server to send all requests for the application tier to this URL. In other words, we're just reconfiguring the web front end to treat the internal load balancer as an application server. 

Notice that we're specifying a full URL here, complete with HTTP as the layer 7 protocol and 8080 as the port number. This corresponds to the internal load balancer's listener. Remember that we configured it to listen for HTTP requests on TCP port 8080. 

Once we reconfigure all the web tier instances to point to the internal load balancer, any request from the web tier to the application tier will hit the listener, which again is listening on TCP port 8080. The internal load balancer will then forward these requests along to the target group containing the application server instances. Make sense? Okay, enough talking. Let's go configure this. 

> Show overview diagram

Here I've browsed to the internet‑facing load balancer, which is load balancing among our three web server front ends. Just as we saw earlier, the App Server Information indicates nothing but errors because the web servers are not configured to connect to the application servers using the internal load balancer we just created. So, let's go ahead and remedy that. Let's go ahead and open up SSH sessions to `web1`, `web2` and `web3`. Let's look up the IP address of the internal load balancer. 

To do that we'll do an `nslookup` and then the domain name, and as I said, an internal load balancer's fully qualified domain name is resolvable only within its `VPC`. 

```bash
nslookup internal-app-lb-2010524154.eu-west-3.elb.amazonaws.com
```

Here, it resolves to two private IP addresses. 

```
Server:         172.31.0.2
Address:        172.31.0.2#53

Non-authoritative answer:
Name:   internal-app-lb-2010524154.eu-west-3.elb.amazonaws.com
Address: 172.31.101.136
Name:   internal-app-lb-2010524154.eu-west-3.elb.amazonaws.com
Address: 172.31.102.58
```

The load balancer, because it's using the internal scheme, does not have a publicly routable IP address, nor does it have a publicly resolvable domain name. That means the traffic between our web tier and our application tier is going to stay within the `VPC`. It is not going to ever hit the internet. 

Okay, the first order of business is to destroy the web server container we created earlier. We need to destroy it so we can create a new one that's configured to point to the internal load balancer. So we're going to do a sudo docker ps and we will destroy the container by referencing a portion of its container ID, sudo docker rm and 79 and then ‑f to force deletion. 

```bash
docker ps
```

```bash
docker kill <container id>
docker rm <container id>
```

Now, I'm going to paste in a much longer command. The command is the same as before except for an additional ‑e parameter. This parameter sets an environment variable containing the full URL of the internal load balancer, including the port 8080. The logic of the web front end looks at this environment variable to determine how it should connect to the application tier. So just think of this as reprogramming our web front end and telling it how to connect to the application back end. Make sense? 

```bash
docker run -d -p 80:3000 \
 -h web1 \
 -e API_URL="http://internal-app-lb-2010524154.eu-west-3.elb.amazonaws.com:8080" \
 jaimesalas/todo-app-front:4
```

All right, let's go ahead and hit Enter here, and let's jump over to our SSH session with `web2`. We're going to do the same thing here, sudo docker ps, sudo docker rm, part of the Docker container ID, delete that, and I'm going to paste in another command. There we go. 

```bash
docker ps
```

```bash
docker kill <container id>
docker rm <container id>
```

Notice that the host name here is web2, `‑h web2`, 

```bash
docker run -d -p 80:3000 \
 -h web2 \
 -e API_URL="http://internal-app-lb-2010524154.eu-west-3.elb.amazonaws.com:8080" \
 jaimesalas/todo-app-front:4
```

hit Enter here, and let's jump over please to `web3` now. 

```bash
docker ps
```

```bash
docker kill <container id>
docker rm <container id>
```

```bash
docker run -d -p 80:3000 \
 -h web3 \
 -e API_URL="http://internal-app-lb-2010524154.eu-west-3.elb.amazonaws.com:8080" \
 jaimesalas/todo-app-front:4
```


Here on web3, sudo docker ps, sudo docker rm 6e, and then one last command here and hit Enter. All right. So, web1, web2, and web3 are all pointing to the internal load balancer. 

Next, let's go back over to the EC2 service console and take a look at our load balancers. Go take a look at the web‑lb load balancer, grab the DNS name for that, just go ahead and copy it to your clipboard, open up a new tab, and then let's browse to it. Now, check this out. Look under the App Server Information. It shows the container host name is app3, the protocol is HTTP, and the port is 8080. Let's go ahead and hit F5 to refresh, and this time we get a different application server. So, we know internal load balancing is working. Also, notice the web server, web1. If we refresh again, we get load balanced to another web server, which is the behavior we saw earlier. So this looks great. 

But we've got one more piece of the web application that we need to get working, and that's the database. Notice at the top we've got two buttons, View Data and Enter Data. Let's click on View Data. Now, clicking this button sets off a chain of events. First, the web server that we're connected to reaches out to one of the application servers. The application server then tries to open a connection to a Mongo database, pull all the records from a certain table, and then pass those records back to the web server. The web server then, in turn, should display those records. But, that doesn't happen. Instead, we get a big ugly ERROR: DATABASE SERVER UNAVAILABLE because obviously we haven't set up the database server yet, so that is exactly what we're going to do next.