#!/bin/bash
# Create NATICA on vagrant VMs

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
#!vagrant destroy -f dbnat marsnat
time vagrant up dbnat marsnat
# TIME for dbnat+marsnat creation = ?

echo "Done provisioning: $sdate to " `date` >> $LOG

echo "Done: " `date`
emins=$(((`date +'%s'` - tic)/60))

echo "Vagrant VMs created on $here. ($emins minutes total)" >> $LOG
cat $LOG
