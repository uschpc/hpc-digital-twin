#!/bin/bash
max_nodes=$((10+1))

service_name=headnode

for i in $(seq $max_nodes)
do
docker compose up $service_name -d
sleep 1
service_name=e$i
done
