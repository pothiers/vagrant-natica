# Intended for provisioning of: valley (archive)
#
# after: vagrant ssh
# sudo puppet apply --modulepath=/vagrant/modules /vagrant/manifests/init.pp --noop --graph
# sudo cp -r /var/lib/puppet/state/graphs/ /vagrant/

if versioncmp($::puppetversion,'3.6.1') >= 0 {
  $allow_virtual_packages = hiera('allow_virtual_packages',false)
  Package {
    allow_virtual => $allow_virtual_packages,
  }
}

include augeas

# epel is not needed by the puppet redis module but it's nice to have it
# already configured in the box
include epel

package { ['emacs', 'xorg-x11-xauth', 'cups', 'wireshark-gnome'] : }

user { 'testuser' :
  ensure     => 'present',
  managehome => true,
  password   => '$1$4jJ0.K0P$eyUInImhwKruYp4G/v2Wm1',
  }

class { 'redis':
  version        => '2.8.13',
  redis_max_memory  => '1gb',
}

class { 'irods':
  #!!! Want this to be relative ('../modules/irods/files/setup_irods.input')
  #!!! How?
  setup_input_file =>  '/vagrant/valley/modules/irods/files/setup_irods.input',
}

yumrepo { 'ius':
  descr      => 'ius - stable',
  baseurl    => 'http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/',
  enabled    => 1,
  gpgcheck   => 0,
  priority   => 1,
  mirrorlist => absent,
} -> Package<| provider == 'yum' |>

class { 'python':
  version    => '34u',
  pip        => false,
  dev        => true,
  virtualenv => true,
} ->
package { 'python34u-pip': } ->
file { '/usr/bin/pip':
  ensure => 'link',
  target => '/usr/bin/pip3.4',
} ->
package { 'graphviz-devel': } ->
python::requirements { '/vagrant/requirements.txt': } 

exec { 'dataq':
  command => '/usr/bin/python3 /sandbox/data-queue/setup.py install',
  #!  require => Python::requirements['/vagrant/requirements.txt']
  require => Package['python34u-pip']
  } ->
file {  '/etc/dataq':
  ensure => 'directory',
  mode   => '0644',
  } ->
file {  '/etc/dataq/dq.conf':
  source => '/sandbox/data-queue/data/dq_config.json',
  mode   => '0744',
  } ->
file {  '/var/run/dataq':
  ensure => 'directory',
  mode   => '0777',
  } ->
file {  '/var/log/dataq':
  ensure => 'directory',
  mode   => '0777',
}

file {  '/var/tada':
  ensure => 'directory',
  mode   => '0777',
}
file {  '/var/tada/non-archive':
  ensure => 'directory',
  mode   => '0777',
}
file {  '/var/tada/archive':
  ensure => 'directory',
  mode   => '0777',
}



exec { 'dqsvcpush':
  command => '/usr/bin/dqsvcpush > /var/log/dataq/push.log 2>&1 &',
  require => File['/var/run/dataq'],
}
exec { 'dqsvcpop':
  command => '/usr/bin/dqsvcpop > /var/log/dataq/pop.log 2>&1 &',
  require => File['/var/run/dataq'],
}

# Get from github now. But its in PyPI for when things stabalize!!!
#!python::pip {'daflsim':
#!  pkgname => 'daflsim',
#!  url     => 'https://github.com/pothiers/daflsim/archive/master.zip',
#!}

# Orig is "pre-alpha".  Better to avoid it now. Orig is also python 2.7,
# this branch upgraded to universal -- maybe.
#!python::pip {'irodsclient':
#!  url => 'https://github.com/pothiers/python-irodsclient/archive/master.zip',
#!}


