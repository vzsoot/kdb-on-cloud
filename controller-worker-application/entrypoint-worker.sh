#!/bin/bash

cd /app || exit
/app/q/l64/q "$1" -q -workerId "$WORKER_ID" -controllerAddr "$CONTROLLER_ADDR" -p 5000
