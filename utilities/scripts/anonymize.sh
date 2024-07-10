#!/bin/bash

#log_file="slurm_sacct_epyc64_10days"
#anon_file="slurm_anon_epyc64_10days"

log_file=$1
anon_file=$2
echo "copying log file"
cp $log_file $anon_file


echo "getting usernames"
usernames=$(awk 'BEGIN {FS="|"} NR>1 {print$1}' $log_file | sort | uniq)

echo "getting account names"
accounts==$(awk 'BEGIN {FS="|"} NR>1 {print$10}' $log_file | sort | uniq)


n_usernames=$(echo $usernames | wc -w)
n_accounts=$(echo $accounts | wc -w)

counter=1
for account in $accounts
do
    echo "$account -> account$counter"
    sed_syntax="s/$account/account$counter/g"
    sed -i $sed_syntax $anon_file
    counter=$((counter+1))
done
counter=1

for username in $usernames
do
    echo "$username -> user$counter"
    sed_syntax="s/$username/user$counter/g"
    sed -i $sed_syntax $anon_file
    counter=$((counter+1))
done
