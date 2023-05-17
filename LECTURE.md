# KDB+ Q on The Cloud

## Create a simple application
### Application logging in every two seconds
Using logging library from https://github.com/prodrive11/log4q 

Code: [simple-application-logging.q](simple-application/simple-application-logging.q)
```bash
q ./simple-application-logging.q -q
```
## Containerize the application ([official docs](https://code.kx.com/insights/1.5/core/install.html#run-in-docker))
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

Check running processes, the kernel version inside and outside the container.

Could we install something?

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

## Simple application doing CSV transformations
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
docker container stop simple-application-csv-filesystem-{1..3}
```

## Deploy to Kubernetes (Kind)
Using [k9s](https://k9scli.io/topics/install/) to navigate K8S

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
### Introduce Cloud storage ([official docs](https://code.kx.com/insights/1.5/core/objstor/main.html))
Create simple application with cloud storage access [simple-application-csv-cloud.q](simple-application/simple-application-csv-cloud.q)

Let's build it
```bash
./build.sh simple-application/simple-application-csv-cloud.Dockerfile simple-application-csv-cloud
```

Run it in docker to test with secrets
```bash
docker run -d --name simple-application-csv-cloud-container -e AZURE_STORAGE_ACCOUNT="???" -e AZURE_STORAGE_SHARED_KEY="???" simple-application-csv-cloud
```

### Share the image with Azure (ACR - Azure Container Registry)
Login to the registry with docker
```bash
docker login <registry server host>
```

Tag the image for the registry host
```bash
docker tag simple-application-csv-cloud:latest <registry server host>/simple-application-csv-cloud:0.0.1
```

Push the image to the registry
```bash
docker push simple-application-csv-cloud:latest <registry server host>/simple-application-csv-cloud:0.0.1
```

### Reuse previous deployment with secrets
Slightly modified deployment for AKS [simple-application-replicaset-aks.yaml](deploy/k8s/simple-application-replicaset-aks.yaml)

Deploy the definition
```bash
kubectl apply -f deploy/k8s/simple-application-replicaset-aks.yaml -n simple-application
```

### Scale up workers

Scale up to something big

```bash
kubectl -n simple-application scale replicaset/simple-application --replicas=500
```
