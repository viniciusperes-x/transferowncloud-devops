#!/bin/bash


yum install docker -y
sleep 10
/etc/init.d/docker start

docker run -d -p 80:80 owncloud:8.1
