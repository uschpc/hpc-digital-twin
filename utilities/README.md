Step 1: 
Login to discovery and run the following command (save stdout to "slurm_sacct_epyc64_10days" for example): 

```
sacct --starttime 03/18/24 --endtime 03/28/24 --format=User,JobID,Submit,Start,End,TimelimitRaw,ElapsedRaw,ReqCPUS,ReqNodes,Account%15,Partition,QOS,ReqMem,ReqTRES -X -P -a -r epyc-64 > ~/slurm_sacct_epyc64_10days
```

Then delete the first 1 or 2 jobs. If submit time is much earlier than the following jobs.



Step 2: 
Crate a Ubuntu VM on Artemis 
VM Image: Ubuntu 22.04 VM 
Storage changed to 40GB, RAM 32GB,  others leave as default 


Step 3:

Install docker

```
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

 ```
Step 3.1

Install docker rootless mode

```
sudo apt-get install -y uidmap

# https://github.com/docker/desktop-linux/issues/43#issuecomment-1178652998

echo "$USER:100000:65536" >> /etc/subuid
echo "$USER:100000:65536" >> /etc/subgid
dockerd-rootless-setuptool.sh install
systemctl --user start docker


# Write container data in /scratchlocal storage
echo {  "data-root": "/scratchlocal/images"  } >> ~/.config/docker/daemon.json 

# test installation

docker run hello-world
```

Step 4: Clone the ubccr github repo
```
cd /scratchlocal/
git clone https://github.com/ubccr-slurm-simulator/slurm_model.git
mkdir slurm_model/epyc
export INSTALL_PREFIX=/scratchlocal/slurm_model/epyc
cd slurm_model/
#change some compute node and head node settings
cd /scratchlocal/slurm_model/micro2/utils

```

Edit start_compute_node.sh and start_head_node.sh and comment out this line: export SLURM_CONF=/opt/cluster/micro2/etc/slurm.conf

```
nano start_compute_node.sh 
nano start_head_node.sh 
```

Step 5: Set up job data and Virtual cluster
```
cd /scratchlocal
git clone https://github.com/uschpc/hpc-digital-twin.git
cd hpc-digital-twin
cd utilities
```

Copy the slurm job history data and store it inside input folder
```
cp ~/slurm_sacct_epyc64_10days input
export INSTALL_PREFIX=/scratchlocal/slurm_model/epyc
make
make install

```

Step 6: Build Virtual cluster docker container ```
cd /scratchlocal/slurm_model

# Comment out/delete /micro2 line from .dockerignore file


# Manually run build command for now
# will incorprate into makefile later
DOCKER_BUILDKIT=0 docker build  -f SlurmVC_SimRepo.Dockerfile -t carc/slurm_vc:slurm-23-02-sim .

```



Step 7: Prepare simulation
You'll have to some configuration on the VC headnode

```
cd /scratch/local/slurm_model/epyc
docker compose up -d headnode

docker exec -it epyc-headnode-1 bash


# you will have a shell in the headnode container

cd /opt/slurm/etc

./add_system_users.sh

# set slurmdbd.conf permissions

chmod 600 /opt/slurm/etc/slurmdbd.conf
chown slurm:slurm /opt/slurm/etcs/slurmdbd.conf
```


Start simulated workload


```
docker exec -it epyc-headnode-1 /opt/slurm_sim_tools/src/slurmsimtools/run_slurm.py \
-s /opt/slurm \
-e /opt/slurm/etc/ \
-a /opt/slurm/etc/sacctmgr.script \
-t /opt/slurm/etc/epyc64_10days.events \
-r /root/results/test/epyc_dtstart_30 \
-d -v -dtstart 30 --no-slurmd
```
