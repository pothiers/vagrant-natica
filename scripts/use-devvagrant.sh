#!/bin/sh

cfgfiles=/sandbox/puppet-modules/tada-hiera/files

sudo cp $cfgfiles/tada_config.dev-vagrant.json /etc/tada/tada.conf
sudo chmod ugo+r /etc/tada/tada.conf

sudo cp $cfgfiles/irodsEnv.dev ~tada/.irods/.irodsEnv
sudo chown tada ~tada/.irods/.irodsEnv

sudo service dqd restart
