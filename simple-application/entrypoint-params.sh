#!/bin/bash

cd /app || exit
/app/q/l64/q "$1" -q -p 5000 -inputDir /input -outputDir /output
