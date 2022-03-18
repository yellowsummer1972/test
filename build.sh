#!/bin/bash 

img='curlpump'

docker rmi ${img}
docker image prune -f
docker build -t ${img} .
