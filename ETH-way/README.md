# HPC Digital Twin Project - ETH way

1- Get an Artemis VM:
- Image: Docker Engine (Rootless mode)
  - 16 physical cpu
  - 64 logical cpus (important otherwise it won’t work)
  - 16GB memory
Make sure docker works:
```
sudo apt update
sudo apt install docker.io
sudo systemctl start docker
sudo systemctl status docker
```

2- Get the ETH repo:
```
cd /scratchlocal/
git clone https://github.com/eth-cscs/slurm-container.git
cd slurm-container
```

3- Get the `slurm-22.05.2.tar.gz` from this repository
```
mv slurm-22.05.2 slurm-22.05.2.old
wget https://raw.githubusercontent.com/uschpc/hpc-digital-twin/refs/heads/main/ETH-way/slurm-22.05.2.tar.gz
tar -xvf slurm-22.05.2.tar.gz
```

nano into the file `Makefile` and on line 17, remove the option: `--progress=tty`. So, it will be:

```
slurm-*: .PHONY
	docker build $@ -t $@:latest 
```
save and exit.

4- Make and run the docker image
```
sudo su
make slurm-22.05.2
docker run --detach --rm -it -e SLURM_NUMNODES=171 slurm-22.05.2
docker attach **dockerid**
```

5- Once logged in, update the slurm.conf
```
cd /home/spack
sh fix_slurm_conf.sh
```

6- Then, run the slurm job file:
```
python3 create_slurm_jobs.py > output_log &
```

If you don’t want this to be interrupted, run it in Artemis VNC!