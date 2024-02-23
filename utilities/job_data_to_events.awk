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

BEGIN {FS="|"; last_job_submit="2023 10 01 00 00 00"; jobcounter="1"}
NR > 1 { submit_time=slurm_time_convert($3)
        submit_diff=time_diff(submit_time,last_job_submit)
        job_start_time=slurm_time_convert($4)
        job_end_time=slurm_time_convert($5)
        job_duration=time_diff(job_end_time,job_start_time) # time in seconds
        printf("-dt %s -e submit_batch_job | --uid=%s -jid=%s, -sim-walltime %s ",submit_diff,$1,NR-1,job_duration) 
        printf("-t %s -n %s -N %s -A %s -p %s -q %s --mem=%s pseudo.job\n",$6,$7,$8,$9,$10,$11,$12)
        last_job_submit=submit_time
        }
