#!/bin/awk -f

# sacct --starttime 10/01/23 --endtime 10/31/23 -u molguin --format=User,JobID,Submit,Start,End,Timelimit%12,ReqCPUS,ReqNodes,Account%15,Partition,QOS,ReqMem,ReqTRES -X -P

func slurm_time_convert(string){
    gsub(/-/," ",string)
    gsub(/:/," ",string)
    gsub(/T/," ",string)
    return string
}


func time_diff(end_string,start_string){
    diff_int=mktime(end_string)-mktime(start_string)
    return diff_int
}

BEGIN {FS="|"; jobcounter="1"}

NR ==2 {last_job_submit=slurm_time_convert($3)}

NR >= 2 { scale=10
		submit_time=slurm_time_convert($3)
        submit_diff=time_diff(submit_time,last_job_submit)
        job_duration=$7 # time in minutes
		dt=(10.25+0.25*jobcounter)/scale
		#dt=submit_diff/scale+dt
        printf("-dt %.2f -e submit_batch_job | --uid=%s  -sim-walltime %d ",dt,$1,job_duration/scale) 
        printf("-J jobid_%s -t %d -n %s -N %s -A %s -p %s -q %s --mem=%s pseudo.job\n",jobcounter,$6/scale,$8,$9,$10,$11,$12,$13)
        last_job_submit=submit_time
		jobcounter =jobcounter+1
        }
