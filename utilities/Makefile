RAW_JOB_DATA?=input/slurm_sacct_epyc64_10days
ANON_JOB_DATA?=input/slurm_anon_epyc64_10days
EVENTS_FILE?=events/epyc64_10days.events
DOCKER_IMAGE_NAME?=carc/slurm_vc:slurm-23-02-sim
N_COMPUTE_NODES?=78
INSTALL_PREFIX?=./output
DOCKERFILE?=SlurmVC_SimRepo.Dockerfile
TMP_LOGS?=/scratch1/$(USER)/slurm_simulator/logs

	
all :tmp_dir tmp_dir/sacctmgr.script tmp_dir/users.sim $(ANON_JOB_DATA)  $(EVENTS_FILE) tmp_dir/docker-compose.yml

tmp_dir:
	mkdir tmp_dir
events:
	mkdir events

tmp_dir/sacctmgr.script: $(EVENTS_FILE) tmp_dir/users.sim tmp_dir
	./scripts/sacctmgr_script_maker.awk tmp_dir/users.sim > tmp_dir/sacctmgr.script
tmp_dir/users.sim: $(EVENTS_FILE) tmp_dir
	./scripts/generate_users_sim.sh $(EVENTS_FILE) ./tmp_dir

$(ANON_JOB_DATA): $(RAW_JOB_DATA)
	./scripts/anonymize.sh $(RAW_JOB_DATA) $(ANON_JOB_DATA)
$(EVENTS_FILE): events $(ANON_JOB_DATA)
	./scripts/job_data_to_events.awk $(ANON_JOB_DATA) > $(EVENTS_FILE)
	#head -n 10 $(ANON_JOB_DATA) | ./scripts/job_data_to_events.awk  > $(EVENTS_FILE)

tmp_dir/docker-compose.yml:
	python3 ./scripts/compose_maker.py --image_name $(DOCKER_IMAGE_NAME) --nodes $(N_COMPUTE_NODES) --tmp_logs $(TMP_LOGS) --docker_file=$(DOCKERFILE)
	mv docker-compose.yml tmp_dir
.PHONY: dockerimage
dockerimage: $(DOCKERFILE_DIR)/$(DOCKERFILE) 
	cd $(DOCKERFILE_DIR) && \
	docker build  --no-cache -f $(DOCKERFILE) -t $(DOCKER_IMAGE_NAME) .
	#docker build  -f $(DOCKERFILE) -t $(DOCKER_IMAGE_NAME) .

.PHONY: install
install:
	mkdir -p $(INSTALL_PREFIX)/etc
	install -m 0664 ../sim_configs/etc/* $(INSTALL_PREFIX)/etc
	install -m 0664 tmp_dir/docker-compose.yml $(INSTALL_PREFIX)
	install -m 0664 tmp_dir/sacctmgr.script tmp_dir/users.sim $(EVENTS_FILE) $(INSTALL_PREFIX)/etc
	install -m 0775 scripts/add_system_users.sh $(INSTALL_PREFIX)/etc
	install -m 0664 $(DOCKERFILE) $(INSTALL_PREFIX)/..
.PHONY: clean
clean:
	rm tmp_dir/docker-compose.yml tmp_dir/sacctmgr.script tmp_dir/users.sim $(EVENTS_FILE) $(ANON_JOB_DATA)	
	rm -d tmp_dir
	rm $(DOCKERFILE_DIR)/$(DOCKERFILE)
