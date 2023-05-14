#!/bin/bash

export BUILD=./generic-application/.build

mkdir -p $BUILD/q
cp -a ~/q/l64 $BUILD/q/l64
cp ~/q/q.k $BUILD/q/
cp ~/q/lic/kc.lic $BUILD/

docker build -f generic-application/Dockerfile generic-application/. -t generic-application --build-arg BUILD_DIR=".build"
