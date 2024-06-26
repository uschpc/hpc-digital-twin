#!/bin/bash

event_file="slurm_anon_epyc64_10days"
awk 'BEGIN {FS="|"} NR>1 {print $1,$10}' $event_file | sort | uniq | less > tmp

awk '{sub(/user/,"",$1);  \
    sub(/account/,"",$2);  \
    printf("user%d:%d:account%d:%d\n",$1,$1+1000,$2,$2+1000)}'  tmp > users.sim
rm tmp

