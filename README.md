# vagrant-tada

For new replacement for DCI using Puppet, iRODS, Redis, Python

Intended as VM base under Vagrant for python development that makes
use of Redis and iRODS.

Doing "vagrant up" in this directory creates two VMs (mountain,
valley). Tada is installed on both.  Some specifici provisioning is
done to mountain and valley seperately.  Either Mountain or Valley VM
can be used to do "lp -d astro file.fits" to submit file to
archive. Additionally, a ~/.cups/client.conf file containing the
single line:

	ServerName mountain.test.noao.edu:631

can be put on any other machine that has access to mountain. Then the lp can be done from the other machine also.


*NOTE: This uses external modules (which are also used under Foreman)
The are expected to be in: "../puppet-modules/"
(relative to this file)

*NOTE: Modules from puppetforge are installed and committed in the module. That means their version is frozen which may not be what you want
*and is different from the foreman installation*.

