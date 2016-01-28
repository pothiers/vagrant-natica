#!/bin/bash

pushd /home/pothiers/sandbox/vagrant-tada
echo -e "\n###################################################################"
#!echo "Expect full provisioning to take about: 0:30"
#! echo "Expect full provisioning to take about: 0:50 with Perl stuff"
#! echo "Expect full provisioning to take about: 0:40; With Perl stuff, without irods"
echo "Expect full provisioning to take about: 0:17; Without Perl stuff, without irods"

sdate=`date`
echo "Starting: $sdate"

tic=`date +'%s'`
vagrant destroy -f valley mountain
time vagrant up valley mountain
emins=$(((`date +'%s'` - tic)/60))


# For workflow: Edit(manifest);Provision, use:
#! vagrant provision mountain --provision-with puppet

echo "Done provisioning: $sdate to " `date` > tt.out
echo "Try: "                               >> tt.out
echo "  /opt/tada-cli/scripts/raw_post /data/molest-pair/nhs_2014_n14_299403.fits" >> tt.out
echo "  vagrant ssh valley -c /sandbox/tada/tests/smoke/smoke.sh" >> tt.out

echo "Done: " `date`
cat tt.out | mail -s "Try valley! NO CLEAN ($emins)" pothier@email.noao.edu

echo "  vagrant ssh valley -c /sandbox/tada/tests/smoke/smoke.all.sh"


