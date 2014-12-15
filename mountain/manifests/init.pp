# Intended for provisioning of: mountain top

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

package { ['emacs', 'xorg-x11-xauth', 'cups'] : }

user { 'testuser' :
  ensure     => 'present',
  managehome => true,
  password   => '$1$4jJ0.K0P$eyUInImhwKruYp4G/v2Wm1',
}

user { 'tadauser' :
  ensure     => 'present',
  managehome => true,
  # tada"Password"
  password   => '$1$Pk1b6yel$tPE2h9vxYE248CoGKfhR41',
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
file { '/home/tadauser/.irods':
  ensure  => 'directory',
  owner   => 'tadauser',
  group   => 'tadauser',
  require => User['tadauser'],
  } ->
file { '/home/tadauser/.irods/.irodsEnv':
  owner   => 'tadauser',
  group   => 'tadauser',
  source  => '/vagrant/mountain/files/irodsEnv',
  } ->
exec { 'irod-iinit':
  environment => ['HOME=/home/tadauser'],
  command     => '/usr/bin/iinit temppasswd',
  require     => Package['irods-icommands'],
  user        => 'tadauser',
}
#!->
#!exec { 'irod-resource':
#!  environment => ['HOME=/home/tadauser'],
#!  command     => "/usr/bin/iadmin mkresc dciResc 'unixfilesystem' valley.test.noao.edu:${vault}",
#!  require     => Package['irods-icommands'],
#!  user        => 'tadauser',
#!  } 

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
file {  '/etc/tada':
  ensure => 'directory',
  mode   => '0644',
  } ->
file {  '/etc/tada/dq.conf':
  source => '/sandbox/data-queue/data/dq_config.json',
  mode   => '0744',
  } ->
file {  '/var/run/tada':
  ensure => 'directory',
  mode   => '0777',
  } ->
file {  '/var/log/tada':
  ensure => 'directory',
  mode   => '0777',
}

exec { 'dqsvcpush':
  command => '/usr/bin/dqsvcpush > /var/log/tada/push.log 2>&1 &',
  require => File['/var/run/tada'],
}
exec { 'dqsvcpop':
  command => '/usr/bin/dqsvcpop > /var/log/tada/pop.log 2>&1 &',
  require => File['/var/run/tada'],
}

# ASTRO
$astroprinter='astro'
$mountaincache='/var/tada/mountain_cache'
service { 'cups':
  ensure  => 'running',
  enable  => true,
  require => Package['cups'],
  } ->
file {  '/usr/lib/cups/backend/astropost':
  source => '/sandbox/tada/astro/astropost',
  mode   => '0700',
  owner  => 'root',
  group  => 'root',
  } ->
file {  '/usr/lib/cups/lib':
  ensure => directory,
  } ->
file {  '/usr/lib/cups/lib/astro':
  ensure => directory,
  } ->
file {  '/usr/lib/cups/lib/astro/pushfile.sh':
  source => '/sandbox/tada/astro/pushfile.sh',
  mode   => '0555',
  } ->
file { '/var/tada':
  ensure => 'directory',
  mode   => '0777',
  } ->
file { $mountaincache:
  ensure => 'directory',
  mode   => '0777',
  } ->
exec { 'add-astro-printer':
  command => "/usr/sbin/lpadmin -p ${astroprinter} -v astropost:${mountaincache} -E",
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
