#!/bin/bash

n_nodes=10




for hostname in $(echo "headnode"; seq --format="e%g" $n_nodes)
do
	echo $hostname
	mkdir -p results/$hostname/run results/$hostname/log 
	mkdir -p results/$hostname/var/spool results/$hostname/var/state 
done

