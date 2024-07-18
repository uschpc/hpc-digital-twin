FROM centos:7

LABEL description="slurm virtual cluster"

# install dependencies
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

RUN yum -y update && \
    yum -y install --setopt=tsflags=nodocs epel-release && \
    yum -y install --setopt=tsflags=nodocs \
        nc lsof vim mc wget bzip2 git\
        autoconf make gcc gcc-c++ rpm-build \
        openssl openssh-clients openssl-devel openssh-server \
        mariadb-server mariadb-devel \
        munge create-munge-key munge-libs munge-devel \
        readline readline-devel strace \
        hdf5 hdf5-devel pam-devel hwloc hwloc-devel \
        perl perl-ExtUtils-MakeMaker python3 python36-PyMySQL python36-psutil \
        sudo perl-Date* && \
    pip3 install pandas py-cpuinfo


# add users
RUN echo 'root:root' |chpasswd && \
    useradd -m -s /bin/bash slurm && \
    echo 'slurm:slurm' |chpasswd && \
    usermod -a -G wheel slurm && \
    echo "slurm ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    #useradd -m -s /bin/bash user1 && echo 'user1:user' |chpasswd && \
    #useradd -m -s /bin/bash user2 && echo 'user2:user' |chpasswd && \
    #useradd -m -s /bin/bash user3 && echo 'user3:user' |chpasswd && \
    #useradd -m -s /bin/bash user4 && echo 'user4:user' |chpasswd && \
    #useradd -m -s /bin/bash user5 && echo 'user5:user' |chpasswd
	groupadd user

RUN mkdir /root/user_adds
COPY ./user_adds/users.sim ./user_adds/add_system_users.sh /root/user_adds

RUN cd /root/user_adds && ./add_system_users.sh

# copy daemons starters
COPY ./docker/utils/cmd_setup ./docker/utils/cmd_start ./docker/utils/cmd_stop /usr/local/sbin/

# configure sshd
RUN mkdir /var/run/sshd && \
    ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' && \
    ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' && \
    ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N '' && \
    echo 'root:root' |chpasswd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
# uncomment two previous line if there is a need for root access through ssh

# setup munge
RUN echo "secret munge key secret munge key secret munge key" >/etc/munge/munge.key &&\
#RUN create-munge-key  \
    chown -R munge:munge /var/log/munge /run/munge /var/lib/munge /etc/munge &&\
    chmod 400 /etc/munge/munge.key &&\
    cmd_start munged &&\
    munge -n | unmunge &&\
    cmd_stop munged

EXPOSE 22

#configure mysqld
RUN chmod g+rw /var/lib/mysql /var/log/mariadb /var/run/mariadb && \
    mysql_install_db && \
    chown -R mysql:mysql /var/lib/mysql && \
    cmd_start mysqld && \
    mysql -e 'DELETE FROM mysql.user WHERE user NOT LIKE "root";' && \
    mysql -e 'DELETE FROM mysql.user WHERE Host NOT IN ("localhost","127.0.0.1","%");' && \
    mysql -e 'GRANT ALL PRIVILEGES ON *.* TO "root"@"%" WITH GRANT OPTION;' && \
    mysql -e 'GRANT ALL PRIVILEGES ON *.* TO "root"@"localhost" WITH GRANT OPTION;' && \
    mysql -e 'CREATE USER "slurm"@"localhost" IDENTIFIED BY "slurm";' && \
    mysql -e 'CREATE USER "slurm"@"%" IDENTIFIED BY "slurm";' && \
    mysql -e 'GRANT ALL PRIVILEGES ON *.* TO "slurm"@"%" WITH GRANT OPTION;' && \
    mysql -e 'GRANT ALL PRIVILEGES ON *.* TO "slurm"@"localhost" WITH GRANT OPTION;' && \
    mysql -e 'DROP DATABASE IF EXISTS test;' && \
    cmd_stop mysqld

# install mini miniapps
COPY ./miniapps /usr/local/miniapps
RUN cd /usr/local/miniapps && make

# setup entry point
WORKDIR /root

# install slurm
RUN git clone --depth 1   --branch slurm-23-02-sim https://github.com/CeSul/slurm_simulator.git && \
    cd ~/slurm_simulator && mkdir bld_frontend && cd bld_frontend && \
    ~/slurm_simulator/configure --prefix=/opt/slurm --with-munge \
    --disable-x11 --disable-front-end --with-hdf5=no   --enable-debug && \
    make -j install 
#    make -j install && \
#    cd && rm -rf ~/slurm_simulator

# install slurm_sim_tools
RUN cd /opt && \
    git clone --depth 1  --branch master https://github.com/ubccr-slurm-simulator/slurm_sim_tools.git && \
    chown -R slurm:slurm /opt/slurm_sim_tools

# copy cluster configs
COPY ./micro2/etc  /opt/cluster/micro2/etc
COPY ./micro2/etc_frontend /opt/cluster/micro2/etc_frontend
COPY ./micro2/shrinked /opt/cluster/micro2/shrinked
COPY ./micro2/job_traces /opt/cluster/micro2/job_traces
COPY ./micro2/utils /opt/cluster/micro2/utils

# prepere directory layout
RUN mkdir -p /opt/cluster/micro2/run /opt/cluster/micro2/log && \
    mkdir -p /opt/cluster/micro2/var/spool /opt/cluster/micro2/var/state && \
    chown -R slurm:slurm /opt/cluster && \
    chmod 755 /opt/cluster /opt/cluster/micro2 /opt/cluster/micro2/var && \
    chmod 700 /opt/cluster/micro2/var/spool /opt/cluster/micro2/var/state && \
    chown -R slurm:slurm /opt

RUN mkdir -p /var/log/slurm && \
	mkdir -p /var/run/slurm && \
	mkdir -p /var/spool/slurm/ctld && \
	mkdir -p /var/spool/slurm/d && \
	mkdir -p /var/state/ && \
	chown -R slurm:slurm /var/log/slurm /var/run/slurm /var/spool/slurm /var/state

#RUN mkdir -p /root/results/run /root/results/log && \
#    mkdir -p /root/results/var/spool /root/results/var/state && \
#    chown -R slurm:users /root && \
#	chmod -R 770 /root && \
#	chmod -R g+s /root
#RUN mkdir -p /root/result/run /root/result/log && \
#    mkdir -p /root/result/var/spool /root/result/var/state && \
#    chown -R slurm:slurm /root/result && \
#    chown -R slurm:slurm /opt/cluster && \
#    chmod 755 /root/result /opt/cluster/micro2 /opt/cluster /root/result/var && \
#    chmod 700 /root/result/var/spool /root/result/var/state && \
#    chown -R slurm:slurm /opt && \
#    chown -R slurm:slurm /root && \
#    chown -R slurm:slurm /opt

ENTRYPOINT ["/usr/local/sbin/cmd_start"]
CMD ["sshd", "munged", "mysqld", "bash_slurm"]
