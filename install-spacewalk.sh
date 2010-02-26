#!/bin/sh 


#wget -O /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release http://www.redhat.com/security/37017186.txt
#rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release

cd /tmp
wget http://192.168.1.10/oracle.tar

tar xvf oracle.tar

yum install -y --nogpgcheck oracle-xe*.rpm 

/usr/sbin/groupadd -r dba
/usr/sbin/useradd -r -M -g dba -d /usr/lib/oracle/xe -s /bin/bash oracle

#tar xvf oracle-rpms.tar
yum install -y --nogpgcheck oracle-instant*.rpm

#yum install -y oracle-xe-selinux oracle-instantclient-selinux


/etc/init.d/oracle-xe configure <<ORA
9000
1521
spacewalk
spacewalk
y
ORA

echo ".  /usr/lib/oracle/xe/app/oracle/product/10.2.0/server/bin/oracle_env.sh" >> /etc/profile
.  /usr/lib/oracle/xe/app/oracle/product/10.2.0/server/bin/oracle_env.sh

cat > /etc/tnsnames.ora <<'EOF'
XE = 
    (DESCRIPTION = 
       (ADDRESS_LIST = 
          (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521)) 
       ) 
       (CONNECT_DATA = 
          (SERVICE_NAME = xe) 
       ) 
    ) 

EOF

su - oracle -c 'sqlplus / as sysdba' <<EOS
create user spacewalk identified by spacewalk default tablespace users; 
grant dba to spacewalk;
alter system set processes = 400 scope=spfile;
alter system set "_optimizer_filter_pred_pullup"=false scope=spfile; 
alter system set "_optimizer_cost_based_transformation"=off scope=spfile; 
EOS

#cat > /etc/yum.repos.d/spacewalk.repo << 'EOF'
#[spacewalk]
#name=Spacewalk
#baseurl=http://koji.rhndev.redhat.com/mnt/koji/mash/spacewalk-f11/spacewalk-f11-0.6/i386/os/
#baseurl=http://koji.rhndev.redhat.com/mnt/koji/mash/spacewalk-5E/spacewalk-5E-0.6/i386/os/

##baseurl=http://miroslav.suchy.cz/spacewalk/nightly-candidate-f11/i386/os/
##baseurl=http://miroslav.suchy.cz/spacewalk/nightly-candidate/i386/os/
#gpgkey=http://spacewalk.redhat.com/yum/RPM-GPG-KEY-spacewalk
#enabled=1
#gpgcheck=0

#EOF

BASEARCH=$(uname -i)
rpm -Uvh http://download.fedora.redhat.com/pub/epel/testing/5/$BASEARCH/python-dmidecode-3.10.7-3.el5.$BASEARCH.rpm
rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/$BASEARCH/epel-release-5-3.noarch.rpm

rpm -Uvh http://spacewalk.redhat.com/yum/0.8/RHEL/5/i386/spacewalk-client-repo-0.8-1.el5.noarch.rpm
wget -O /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release http://www.redhat.com/security/37017186.txt
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release


echo "Next up: yum install spacewalk"

#yum install --nogpgcheck -y *.rpm
#yum install -y spacewalk


