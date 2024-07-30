#!/usr/bin/awk -f
BEGIN {
FS=":"
print("# add/modify QOS ")
print("modify QOS set normal Priority=0 ")
print("add QOS Name=supporters Priority=100 \n")
print("# add cluster \n")
print("add cluster Name=micro Fairshare=1 \n")
#print("add cluster Name=micro Fairshare=1 QOS=normal,supporters\n")
print("add account name=account0 Fairshare=100\n")
print("add user name=admin DefaultAccount=account0 MaxSubmitJobs=1000 AdminLevel=Administrator\n")
#account_list=[]
}
# add users and accounts
{ 
	username=$1
	account=$3
	if (account_list[account] ==0 ) {
	#	print("New account!")
		account_list[account]=1
		printf("\nadd account name=%s Fairshare=100\n",account)
	}
	else{
	#	print("Old account!")
	}
	printf("add user name=%s DefaultAccount=%s MaxSubmitJobs=1000\n",username,account)
}

END {
print("\nmodify user set qoslevel=\"normal,supporters\"")
print("list associations format=Account,Cluster,User,Fairshare tree withd")
}
