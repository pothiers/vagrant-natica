#!/bin/bash
# To recreate TADA and MARS on vagrant VMs and run full smoke, do:
#    vagrant destroy -f mars; vagrant up mars; ./tt0

LOG=/tmp/create-tada-tt.$$.log
here=`hostname`
now=`date`
echo "Creating VMs on $here at $now"  > $LOG
pushd /home/pothiers/sandbox/vagrant-tada
echo -e "\n###################################################################"
#!echo "Expect full provisioning to take about: 0:30"
#! echo "Expect full provisioning to take about: 0:50 with Perl stuff"
#! echo "Expect full provisioning to take about: 0:40; With Perl stuff, without irods"
#! echo "Expect full provisioning to take about: 0:17; Without Perl stuff, without irods"
echo "Expect full provisioning to take about: 0:33; With smoke test"

sdate=`date`
echo "Starting: $sdate"

tic=`date +'%s'`
vagrant destroy -f valley mountain
# Must bring up MARS first because
#    tada/scripts/tada-valley-install.sh
# uses tables from MARS during tada install!
time vagrant up mars valley mountain 


# For workflow: Edit(manifest);Provision, use:
#! vagrant provision mountain --provision-with puppet

echo "Done provisioning: $sdate to " `date` >> $LOG
#!echo "Try: "                                >> $LOG
#!echo "  /opt/tada-cli/scripts/raw_post /data/molest-pair/nhs_2014_n14_299403.fits" >> $LOG
#!echo "  vagrant ssh valley -c /sandbox/tada/tests/smoke/smoke.sh" >> $LOG


#echo "DISABLED auto run of smoke tests"
#echo "  vagrant ssh valley -c /opt/tada/tests/smoke/smoke.all.sh: " `date`
#vagrant ssh valley -c /sandbox/tada/tests/smoke/smoke.all.sh          >> $LOG
echo "  run-smoke-as-tester.sh: " `date`
~/sandbox/tada/tests/smoke/run-smoke-as-tester.sh                     >> $LOG

echo "Done: " `date`
emins=$(((`date +'%s'` - tic)/60))
echo "See attachment for log of smoke.all.sh" | mail -n -a $LOG -s "Vagrant VMs created on $here. Smoke run. ($emins minutes total)" pothier@email.noao.edu
# cat $LOG



