#!/bin/bash
# Create TADA and MARS-NATICA on vagrant VMs 

LOG=$HOME/create-natica-tt.$$.log
here=`hostname`
now=`date`
echo "Writing log to: $LOG"
echo "Creating VMs on $here at $now"  > $LOG
pushd $HOME/sandbox/vagrant-natica
echo -e "\n###################################################################"
echo "Expect full provisioning to take about: 0:33; With smoke test"

sdate=`date`
echo "Starting: $sdate"

tic=`date +'%s'`
#!vagrant destroy -f mtnnat valnat dbnat marsnat
#!time vagrant up mtnnat valnat dbnat marsnat
vagrant destroy -f dbnat marsnat
time vagrant up dbnat marsnat
# TIME for dbnat+marsnat creation = ?

# For workflow: Edit(manifest);Provision, use:
#! vagrant provision mtnnat --provision-with puppet
#! vagrant provision marsnat --provision-with puppet

echo "Done provisioning: $sdate to " `date` >> $LOG

echo "Done: " `date`
emins=$(((`date +'%s'` - tic)/60))
#!echo "See attachment for log of smoke.all.sh" | mail -n -a $LOG -s "Vagrant VMs created on $here. Smoke run. ($emins minutes total)" pothier@email.noao.edu

echo "Vagrant VMs created on $here. Smoke run. ($emins minutes total)" >> $LOG
cat $LOG
echo "TOTAL SCORE:"
grep "Multi-test score" $LOG

