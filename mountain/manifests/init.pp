# Intended for provisioning of: mountain top

include augeas

# epel is not needed by the puppet redis module but it's nice to have it
# already configured in the box
include epel

package { ['emacs', 'xorg-x11-xauth', 'cups'] : }

user { 'testuser' :
  ensure     => 'present',
  managehome => true,
  password   => '$1$4jJ0.K0P$eyUInImhwKruYp4G/v2Wm1',
}

class { 'redis':
  version           => '2.8.13',
  redis_max_memory  => '1gb',
}

package { 'telnet': }

$irodsbase = 'ftp://ftp.renci.org/pub/irods/releases/4.0.3'
package { ['fuse-libs','openssl098e']: } ->
package { 'irods-icommands':
  provider => 'rpm',
  source   => "${irodsbase}/irods-icommands-4.0.3-64bit-centos6.rpm",
  } 

$vault='/var/lib/irods/iRODS/dciVault'
file { '/home/testuser/.irods':
  ensure  => 'directory',
  owner   => 'testuser',
  group   => 'testuser',
  require => User['testuser'],
  } ->
file { '/home/testuser/.irods/.irodsEnv':
  owner   => 'testuser',
  group   => 'testuser',
  source  => '/vagrant/mountain/files/irodsEnv',
  } ->
exec { 'irod-iinit':
  environment => ['HOME=/home/testuser'],
  command     => '/usr/bin/iinit temppasswd',
  require     => Package['irods-icommands'],
  user        => 'testuser',
  } ->
exec { 'irod-resource':
  environment => ['HOME=/home/testuser'],
  command     => "/usr/bin/iadmin mkresc dciResc 'unixfilesystem' valley.test.noao.edu:${vault}",
  require     => Package['irods-icommands'],
  user        => 'testuser',
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
package { 'graphviz-devel': }

python::requirements { '/vagrant/requirements.txt':
  require => Package['python34u-pip']
} 

exec { 'dataq':
  command => '/usr/bin/python3 /sandbox/data-queue/setup.py install',
  #!  require => Python::requirements['/vagrant/requirements.txt']
  require => Package['python34u-pip']
  } ->
file {  '/var/run/dataq':
  endure => 'directory',
  mode   => '0777',
  } ->
file {  '/var/log/dataq':
  endure => 'directory',
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

# ASTRO
$astroprinter='astro'
$mountaincache='/var/tada/mountain_cache'
service { 'cups':
  ensure => 'running',
  enable => true,
  } ->
file {  '/usr/lib/cups/backend/astropost':
  source => '/sandbox/tada/astro/astropost',
  mode   => '0700',
  } ->
file {  '/usr/lib/cups/lib/astro/pushfile.sh':
  source => '/sandbox/tada/astro/pushfile.sh',
  mode   => '0555',
  } ->
file { $mountaincache:
  mode   => '0777',
  } ->
exec { 'add-astro-printer':
  command => "lpadmin -p ${astroprinter} -v astropost:${mountaincache} -E",
  }




#!# Get from github now. But its in PyPI for when things stabalize!!!
#!python::pip {'daflsim':
#!  pkgname => 'daflsim',
#!  url     => 'https://github.com/pothiers/daflsim/archive/master.zip',
#!  }->
#!python::pip {'dataq':
#!  pkgname       => 'dataq',
#!  #!url         => 'git+git@github.com:pothiers/data-queue.git#egg=dataq',
#!  url           => '/sandbox/data-queue',
#!  install_args  => ['-e'],
#!  }->
#!exec { 'dataq-push-svc':
#!  command => '/usr/bin/dataq_push_svc.py',
#!  } 
