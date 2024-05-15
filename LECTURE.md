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
docker build -f sleep.Dockerfile -t simple-application-sleep .
```

List images
```bash
docker image ls -a | grep simple
```

### Run image as a container
Run image
```bash
docker run -d --name simple-application-sleep-container simple-application-sleep
```

List running containers
```bash
docker container ls -a | grep simple
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
q ./simple-application-csv-filesystem.q -q -inputDir ../data/input -outputDir ../data/output
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
docker run -d --name simple-application-csv-filesystem-1 -v $(pwd)/data/input:/input -v $(pwd)/data/output:/output simple-application-csv-filesystem
```

### Create more instances
```bash
docker run -d --name simple-application-csv-filesystem-2 -v $(pwd)/data/input:/input -v $(pwd)/data/output:/output simple-application-csv-filesystem
docker run -d --name simple-application-csv-filesystem-3 -v $(pwd)/data/input:/input -v $(pwd)/data/output:/output simple-application-csv-filesystem
```

List them
```bash
docker container ls -a
```

Watch all the logs
```bash
watch 'docker ps -q | xargs -L 1 docker logs --tail=10'
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
Deployment definition [simple-application-deployment.yaml](deploy/k8s/simple-application-deployment.yaml)

Apply the deployment
```bash
kubectl create namespace simple-application 
kubectl apply -n simple-application -f deploy/k8s/simple-application-deployment.yaml
```

Give the image to Kind
```bash
kind load docker-image simple-application-logging:0.0.1
```

### Scale up/down workers
Scale the number of workers to 10
```bash
kubectl -n simple-application scale deployment/simple-application --replicas=10
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
Slightly modified deployment for AKS [simple-application-deployment-aks.yaml](deploy/k8s/simple-application-deployment-aks.yaml)

Deploy the definition
```bash
kubectl apply -f deploy/k8s/simple-application-deployment-aks.yaml -n simple-application
```

### Scale up workers

Scale up to something big

```bash
kubectl -n simple-application scale deployment/simple-application --replicas=500
```

## Controller-Worker application
Create a **controller** application with a task queue and task handling API [controller.q](controller-worker-application/controller.q)

Create a **worker** application that connects to the controller and executes the next task in the task [worker.q](controller-worker-application/worker.q)

### Run the agents locally

Start the **Controller**
```bash
q ./controller.q -p 5000 -q
```

Start the **Worker** providing the controller address and ID 
```bash
q ./worker.q -q -controllerAddr ":5000" -workerId "localWorker"
```

### Containerize agents

Run build command
```bash
./build-controller-worker-application.sh controller-worker-application/worker.Dockerfile application-worker
./build-controller-worker-application.sh controller-worker-application/controller.Dockerfile application-controller
```

### Run from docker

Start up the **Controller** and publish the port

```bash
docker run -d --name application-controller -p 5000:5000 -e CONTROLLER_PORT=5000 application-controller
```

Watch the **Controller** logs:
```bash
watch docker logs application-controller
```

Start up two **Workers**
```bash
docker run -d --name application-worker-1 -e CONTROLLER_ADDR=192.168.16.1:5000 -e WORKER_ID=dockerWorker1 application-worker
docker run -d --name application-worker-2 -e CONTROLLER_ADDR=192.168.16.1:5000 -e WORKER_ID=dockerWorker2 application-worker
```

Add sample tasks to the **Controller**
```text
// sample tasks with priorities
addTask[({INFO "add1"; :x+y}; 1;1); 17]
addTask[({INFO "add2"; :x+y}; 2;2); 7]
addTask[({INFO "add3"; :x+y}; 3;3); 9]
addTask[({INFO "add4"; :x+y}; 4;4); 9]
addTask[({INFO "add5"; :x+y}; 5;5); 1]
```

## Deploy Controller-Worker application to AKS

Prepare images and share with the remote registry
```bash
docker tag application-controller:latest bmekdboncloud.azurecr.io/application-controller:0.0.1
docker tag application-worker:latest bmekdboncloud.azurecr.io/application-worker:0.0.1
docker push bmekdboncloud.azurecr.io/application-controller:0.0.1
docker push bmekdboncloud.azurecr.io/application-worker:0.0.1
```

Create **Controller** service by defining a domain and a load balancer for the **Controller** deployment
```bash
kubectl apply -f deploy/k8s/application-controller-service.yaml -n simple-application
```

Create a **Controller** and a **Worker** deployment

```bash
kubectl apply -f deploy/k8s/application-controller-deployment-aks.yaml -n simple-application
kubectl apply -f deploy/k8s/application-worker-deployment-aks.yaml -n simple-application
```

## Let's do some large data analysis
