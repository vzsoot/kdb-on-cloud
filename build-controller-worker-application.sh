#!/bin/bash

export BUILD=./controller-worker-application/.build

rm -rf $BUILD; mkdir -p $BUILD
cp -a ~/q $BUILD/q
cp ~/qlic/k4.lic $BUILD/

docker build -f "$1" controller-worker-application/. -t "$2" --build-arg BUILD_DIR=".build" --build-arg LOAD_Q=""
