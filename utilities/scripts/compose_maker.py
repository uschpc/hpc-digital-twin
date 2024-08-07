import argparse



outfile="docker-compose.yml"

preamble="""services: \n"""
head_node_command='["sshd", "munged", "mysqld", "-loop"]'
compute_node_command='["sshd", "munged", "/opt/cluster/micro2/utils/start_compute_node.sh", "-loop"]'
node_string="""  {hostname}: 
    image: docker.io/{image_name}
    hostname: {hostname}
    build:
        context: ..
        dockerfile: {dockerfile}
    shm_size: 64M
    command: {command}
    networks: 
      network1:  
        ipv4_address: {ip_address}
    expose: 
      - '6817'
      - '6818'
      - '6819'
    volumes: 
      - './results/{hostname}:/root/results'
      - './etc:/opt/slurm/etc'
      - './results/home:/home'
      - '{tmp_logs}/{hostname}/var/spool/slurm:/var/spool/slurm'
      - '{tmp_logs}/{hostname}/var/state/:/var/state'
      - '{tmp_logs}/{hostname}/var/state/:/var/state'
      - '{tmp_logs}/{hostname}/var/log/slurm/:/var/log/slurm'
      #- '{tmp_logs}/{hostname}/var/run/:/var/run'
"""
networkstring="""
networks: 
  network1: 
    driver: bridge
    ipam: 
      driver: default
      config:
        - subnet: 172.32.3.0/24
          gateway: 172.32.3.1
"""

parser = argparse.ArgumentParser(description='Generate docker-compose.yml file for Slurm simulator')
parser.add_argument('-n','--nodes',nargs='?',default=171,type=int,help='Number of nodes in simulated cluster')
parser.add_argument('--image_name','-i',nargs='?',default='carc/slurm_vc:slurm-22-08-sim',type=str,help='Which docker container to use')
parser.add_argument('--docker_file','-d',nargs='?',default='SlurmVC_SimRepo.Dockerfile',type=str,help='Which docker file to build')
parser.add_argument('--tmp_logs','-t',nargs='?',default='/tmp',type=str,help='Where to save slurm log data')
args=parser.parse_args()

with open(outfile,'w') as f:

	hostname='headnode'
	ip_address=f'172.32.3.254'
	command=head_node_command



	f.write(preamble)
	for i in range(1,args.nodes+2):
		f.write(node_string.format(hostname=hostname,command=command,dockerfile=args.docker_file,ip_address=ip_address,image_name=args.image_name,tmp_logs=args.tmp_logs) )
		hostname=f'e{i}'
		command=compute_node_command
		if (i==1):
			ip_address=f'172.32.3.{args.nodes+1}'
			
		else:
			ip_address=f'172.32.3.{i}'
	f.write(networkstring)
