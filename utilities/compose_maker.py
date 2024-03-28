outfile="docker-compose.yml"
n_compute=10
image_name="carc/slurm_vc:slurm-20.02-sim"

preamble="""version: "3.3"\nservices: \n"""
head_node_command='["sshd", "munged", "mysqld", "-loop"]'
compute_node_command='["sshd", "munged", "/opt/cluster/micro2/utils/start_compute_node.sh", "-loop"]'
node_string="""  {hostname}: 
    image: {image_name}
    hostname: {hostname}
    shm_size: 64M
    command: {command}
    networks: 
      network1:  
        ipv4_address: {ip_address}
    volumes: 
      - './results/{hostname}:/root/results'
      - './etc:/opt/slurm/etc'
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

with open(outfile,'w') as f:

	hostname='headnode'
	ip_address='172.32.3.172'
	command=head_node_command



	f.write(preamble)
	for i in range(1,n_compute+2):
	#for i in range(1,3):
		f.write(node_string.format(hostname=hostname,command=command,ip_address=ip_address,image_name=image_name))
		hostname=f'e{i}'
		command=compute_node_command
		if i==1:
			ip_address=f'172.32.3.{n_compute+1}'
		else:
			ip_address=f'172.32.3.{i}'
	f.write(networkstring)
