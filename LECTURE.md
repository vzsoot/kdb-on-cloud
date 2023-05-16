# KDB+ Q on The Cloud

## Create a simple application
### Application logging in every two seconds
[simple-application-logging.q](simple-application/simple-application-logging.q)
```bash
q ./simple-application-logging.q -q
```
## Containerize the application
### Create an "empty" image
Dockerfile with minimal content: [sleep.Dockerfile](simple-application/sleep.Dockerfile)

Build and tag image
```bash
docker build -f Dockerfile.sleep -t simple-application-sleep .
```

List images
```bash
docker image ls -a
```

### Run image as a container
Run image
```bash
docker run -d --name simple-application-sleep-container simple-application-sleep
```

List running containers
```bash
docker container ls -a
```

### Exec into the container

Execute bash inside the container 
```bash
docker exec -it simple-application-sleep-container /bin/bash
```

Investigate processes, kernel version inside and outside the cluster.

### Include Q and the application
Build script to prepare and run the build: [build.sh](build.sh)
Dockerfile with application: [simple-application-logging.Dockerfile](simple-application/simple-application-logging.Dockerfile)

Create image using the above dockerfile to produce image with tag __simple-application-loggin__
```bash
./build.sh simple-application/simple-application-logging.Dockerfile simple-application-loggin
```

Run container
```bash
docker run -d --name simple-application-logging-container simple-application-loggin
```

Follow the logs
```bash
watch docker logs simple-application-logging-container
```

## Generic application doing CSV transformations
### Use folders to input, transform then output the result
### Migrate into the container
### Start using mounts
### Create more instances
## Deploy to Kubernetes (Kind)
### Pods and Deployments
### Mount local disk
### Scale up/down workers
## Deploy to AKS (Azure Kubernetes Services)
### Introduce Cloud storage
### Secrets are important
### Reuse previous deployment
### Scale up workers
