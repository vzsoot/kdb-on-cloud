#!/bin/bash

# deploy K8S web dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# local proxy to k8s
kubectl proxy &

# apply RBAC
kubectl apply -f ./kubernetes-dashboard-config.yaml

# require token
kubectl -n kubernetes-dashboard create token admin-user
