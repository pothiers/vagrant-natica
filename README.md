vagrant-tada
============

For new replacement for DCI using Puppet, iRODS, Redis, Python

Intended as VM base under Vagrant for python development that makes
use of Redis and iRODS.

Doing "vagrant up" in this directory creates two VMs (mountain, valley). Tada is installed on both.  Some specifici provisioning is done to mountain and valley seperately.  Either Mountain or Valley VM can be used to do "lp -d astro file.fits" to submit file to archive. Additionally, a ~/.cups/client.conf file containing the single line:

	ServerName mountain.test.noao.edu:631

can be put on any other machine that has access to mountain. Then the lp can be done from the other machine also.


*NOTE: This uses a "git submodule"!*  Initialize local configuration:

       git submodule init
       git submodule update

