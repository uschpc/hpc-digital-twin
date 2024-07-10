RAW_JOB_DATA?=input/slurm_sacct_epyc64_10days
ANON_JOB_DATA?=input/slurm_anon_epyc64_10days
EVENTS_FILE?=events/epyc64_10days.events

sacctmgr.script: $(EVENTS_FILE) user.sim
	./scripts/sacctmgr_script_maker.awk users.sim > sacctmgr.script

user.sim: $(EVENTS_FILE)
	./scripts/generate_users_sim.sh $(EVENTS_FILE) .

$(EVENTS_FILE): $(ANON_JOB_DATA)
	./scripts/job_data_to_events.awk $(ANON_JOB_DATA) > $(EVENTS_FILE)

$(ANON_JOB_DATA): $(RAW_JOB_DATA)
	./scripts/anonymize.sh $(RAW_JOB_DATA) $(ANON_JOB_DATA)

