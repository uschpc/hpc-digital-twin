#!/bin/bash

#job_log="slurm_anon_epyc64_10days"
job_log=$1
output_dir=$2
awk '{split($6,array,"=");print array[2],$18}' $job_log | sort | uniq > tmp

awk '{sub(/user/,"",$1);  \
    sub(/account/,"",$2);  \
    printf("user%d:%d:account%d:%d\n",$1,$1+1000,$2,$2+1000)}'  tmp > "$output_dir/users.sim"
rm tmp

