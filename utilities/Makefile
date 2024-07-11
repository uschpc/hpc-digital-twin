RAW_JOB_DATA?=input/slurm_sacct_epyc64_10days
ANON_JOB_DATA?=input/slurm_anon_epyc64_10days
EVENTS_FILE?=events/epyc64_10days.events
DOCKER_IMAGE_NAME?=carc/slurm_vc:slurm-20.02-sim
N_COMPUTE_NODES?=171
INSTALL_PREFIX?=./output


tmp_dir:
	mkdir tmp_dir
	
all :tmp_dir/sacctmgr.script tmp_dir/users.sim $(ANON_JOB_DATA)  $(EVENTS_FILE) tmp_dir/docker-compose.yml


tmp_dir/sacctmgr.script: $(EVENTS_FILE) tmp_dir/users.sim
	./scripts/sacctmgr_script_maker.awk tmp_dir/users.sim > tmp_dir/sacctmgr.script
tmp_dir/users.sim: $(EVENTS_FILE)
	./scripts/generate_users_sim.sh $(EVENTS_FILE) ./tmp_dir

$(ANON_JOB_DATA): $(RAW_JOB_DATA)
	./scripts/anonymize.sh $(RAW_JOB_DATA) $(ANON_JOB_DATA)
$(EVENTS_FILE): $(ANON_JOB_DATA)
	./scripts/job_data_to_events.awk $(ANON_JOB_DATA) > $(EVENTS_FILE)

tmp_dir/docker-compose.yml:
	python3 ./scripts/compose_maker.py --image_name $(DOCKER_IMAGE_NAME) --nodes $(N_COMPUTE_NODES)
	mv docker-compose.yml tmp_dir

.PHONY: install
install:
	mkdir -p $(INSTALL_PREFIX)/etc
	install -m 0644 tmp_dir/docker-compose.yml $(INSTALL_PREFIX)
	install -m 0644 tmp_dir/sacctmgr.script tmp_dir/users.sim $(EVENTS_FILE) $(INSTALL_PREFIX)/etc
.PHONY: clean
clean:
	rm tmp_dir/docker-compose.yml tmp_dir/sacctmgr.script tmp_dir/users.sim $(EVENTS_FILE) $(ANON_JOB_DATA)	
	rm -d tmp_dir
