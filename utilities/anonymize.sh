#!/bin/bash

# sacct --starttime 10/01/23 --endtime 10/31/23 -a --format=User,JobID,Submit,Start,End,Timelimit%12,ReqCPUS,ReqNodes,Account%15,Partition,QOS,ReqMem,ReqTRES -X -P

log_file="slurm_sacct_data_v2"
anon_file="slurm_anon"

echo "getting usernames"
usernames=$(awk 'BEGIN {FS="|"} {print$1}' $log_file | sort | uniq)
echo "getting account names"
accounts==$(awk 'BEGIN {FS="|"} {print$9}' $log_file | sort | uniq)


n_usernames=$(echo $usernames | wc -w)
n_accounts=$(echo $accounts | wc -w)

counter=1

echo "copying log file"
cp $log_file $anon_file
for username in $usernames
do
    echo "$username -> user$counter"
    sed_syntax="s/$username/user$counter/g"
    sed -i $sed_syntax $anon_file
    counter=$((counter+1))
done
counter=1
for account in $accounts
do
    echo "$account -> account$counter"
    sed_syntax="s/$account/account$counter/g"
    sed -i $sed_syntax $anon_file
    counter=$((counter+1))
done
