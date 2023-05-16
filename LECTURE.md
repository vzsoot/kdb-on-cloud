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

Create image using the above dockerfile to produce image with tag __simple-application-logging__
```bash
./build.sh simple-application/simple-application-logging.Dockerfile simple-application-logging
```

Run container
```bash
docker run -d --name simple-application-logging-container simple-application-logging
```

Follow the logs
```bash
watch docker logs simple-application-logging-container
```

## Generic application doing CSV transformations
### Use folders to input, transform then output the result
Run [simple-application-csv-filesystem.q](simple-application/simple-application-csv-filesystem.q)

```bash
q ./simple-application-csv-filesystem.q -q -inputDir input -outputDir output
```

### Migrate into the container
Updated Dockerfile [simple-application-csv-filesystem.Dockerfile](simple-application/simple-application-csv-filesystem.Dockerfile)

Let's build it
```bash
./build.sh simple-application/simple-application-csv-filesystem.Dockerfile simple-application-csv-filesystem
```

### Start using mounts
Run container with mounts
```bash
docker run -d --name simple-application-csv-filesystem-1 -v $(pwd)/input:/input -v $(pwd)/output:/output simple-application-csv-filesystem
```

### Create more instances
```bash
docker run -d --name simple-application-csv-filesystem-2 -v $(pwd)/input:/input -v $(pwd)/output:/output simple-application-csv-filesystem
docker run -d --name simple-application-csv-filesystem-3 -v $(pwd)/input:/input -v $(pwd)/output:/output simple-application-csv-filesystem
```

List them
```bash
docker container ls -a
```

Stop them all
```bash
docker container stop simple-application-csv-filesystem-{1..2}
```

## Deploy to Kubernetes (Kind)
Tag our image with a version
```bash
docker tag simple-application-logging:latest simple-application-logging:0.0.1
```

### Pods and Deployments
Deployment definition [simple-application-replicaset.yaml](deploy/k8s/simple-application-replicaset.yaml)

Deploy the ReplicaSet
```bash
kubectl apply -n simple-application -f deploy/k8s/simple-application-replicaset.yaml
```

Give the image to Kind
```bash
kind load docker-image simple-application-logging:0.0.1
```

### Scale up/down workers
Scale the number of workers to 10
```bash
kubectl -n simple-application scale replicaset/simple-application --replicas=10
```

## Deploy to AKS (Azure Kubernetes Services)
### Introduce Cloud storage
### Secrets are important
### Reuse previous deployment
### Scale up workers
