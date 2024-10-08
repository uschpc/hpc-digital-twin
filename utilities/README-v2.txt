
Step 1: 
Login to discovery and run the following command (save stdout to "slurm_sacct_epyc64_10days" for example): 

sacct --starttime 03/18/24 --endtime 03/28/24 --format=User,JobID,Submit,Start,End,TimelimitRaw,ElapsedRaw,ReqCPUS,ReqNodes,Account%15,Partition,QOS,ReqMem,ReqTRES -X -P -a -r epyc-64 > ~/slurm_sacct_epyc64_10days

Step 2: 
Crate a Ubuntu VM on Artemis 
VM Image: Ubuntu 22.04 VM 
Storage changed to 40GB, RAM 32GB,  others leave as default 

Step 3:
cd /scratchlocal
mkdir tutorial
cd tutorial
mkdir slurm_model
cd slurm_model
git clone https://github.com/uschpc/hpc-digital-twin.git
cd hpc-digital-twin
cd utilities

# copy the slurm job history data and store it inside input folder
cp ~/slurm_sacct_epyc64_10days input
make
cd /scratchlocal/tutorial/slurm_model
mkdir epyc
cd hpc-digital-twin/utilities/
export INSTALL_PREFIX=/scratchlocal/tutorial/slurm_model/epyc
make install
make dockerfile
sudo su


Step 4: 
# now you are in the root user of Ubuntu VM

4.1 Install Docker within VM
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

#the foloowing line will ask you to choose yes or no,  choose yes
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo docker run hello-world

4.2 Clone the ubccr github repo
cd /scratchlocal/
rm -rf slurm_model
git clone https://github.com/ubccr-slurm-simulator/slurm_model.git
export INSTALL_PREFIX=/scratchlocal/slurm_model/epyc
cd slurm_model/
mv .dockerignore .dockerignore_bkp-1
systemctl start docker
docker pull centos:7

4.3 Make docker image (This would take 5-10 mints or so) 
cd /scratchlocal/tutorial/slurm_model/hpc-digital-twin/utilities
make dockerimage

4.4 Edit docker compose file 
cd /scratchlocal/tutorial/slurm_model/epyc

#Edit docker-compose.yml, change e1 ipv4_address from 172.32.3.1 to 172.32.3.173
nano docker-compose.yml

#docker compose up -d 

4.5 Copy config settings to the slurm epyc folder 
cp -r /scratchlocal/tutorial/slurm_model/hpc-digital-twin/sim_configs/etc/ /scratchlocal/tutorial/slurm_model/epyc/

4.6 Change some compute node and head node settings
cd /scratchlocal/slurm_model/micro2/utils

# Edit start_compute_node.sh and start_head_node.sh and comment out this line: export SLURM_CONF=/opt/cluster/micro2/etc/slurm.conf
nano start_compute_node.sh 
nano start_head_node.sh 

docker container prune
cd /scratchlocal/tutorial/slurm_model/hpc-digital-twin/utilities/
export INSTALL_PREFIX=/scratchlocal/tutorial/slurm_model/epyc
make dockerfile
make dockerimage
cd /scratchlocal/tutorial/slurm_model/epyc/
docker compose up -d

# 
docker exec -it epyc-headnode-1 bash

# add system users

cd /opt/slurm/etc
./add_system_users.sh

# set slurmdbd.conf permissions

chmod 600 /opt/slurm/etc/slurmdbd.conf
chown slurm:slurm /opt/slurm/etcs/slurmdbd.conf


# leave headnode container

#to start simulated workload

docker exec -it epyc-headnode-1 /opt/slurm_sim_tools/src/slurmsimtools/run_slurm.py \
-s /opt/slurm \
-e /opt/slurm/etc/ \
-a /opt/slurm/etc/sacctmgr.script \
-t /opt/slurm/etc/epyc64_10days.events \
-r /root/results/test/epyc_dtstart_30 \
-d -v -dtstart 30 --no-slurmd



