#!/bin/bash
echo "Adding users to the system..."
if [[ "`hostname`" == "headnode" ]]; then
    echo "headnode."
    USERADD_FLAG="-m"
else
    echo "computenode."
    USERADD_FLAG="-M"
fi
USERADD_FLAG="${USERADD_FLAG} -N -g users"

for line in $(cat users.sim)
do
	username=$(echo $line | cut -d ":" -f 1)
	uid=$(echo $line | cut -d ":" -f 2)
	group=$(echo $line | cut -d ":" -f 3)
	gid=$(echo $line | cut -d ":" -f 4)
	echo "${username}:user"
	echo "${username}:user" | chpasswd
	useradd ${USERADD_FLAG} -u $uid -s /bin/bash ${username}
done
useradd ${USERADD_FLAG} -u 2000 -s /bin/bash nikolays 
