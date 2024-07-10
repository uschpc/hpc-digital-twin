import numpy as np
import re
filename="events_bag.txt"
outfile="events500_epyc64_10days.txt"
with open(filename) as file:
    lines=[line.rstrip() for line in file]

random_jobs=np.random.choice(lines,500)

with open(outfile, 'w') as outfile:
    time_counter=0
    jid_counter=1
    for job in random_jobs:

        job_update=re.sub(r"-jid=[0-9]+",f"-jid={jid_counter}",job)
        jid_counter+=1

        match_string=r"-dt [0-9]+"
        dt_match=re.match(match_string,job)
        time_offset=int(dt_match[0][4:])
        time_counter+=time_offset
        job_update=re.sub(match_string,f"-dt {time_counter}",job_update)

        outfile.write(job_update+"\n")

