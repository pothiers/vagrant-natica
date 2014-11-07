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
  version        => '2.8.13',
  redis_password => 'test',
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
  environment => ["HOME=/home/testuser"],
  command => "/usr/bin/iinit temppasswd",
  require => Package['irods-icommands'],
  user    => 'testuser',
  } ->
exec { 'irod-resource':
  environment => ["HOME=/home/testuser"],
  command => "/usr/bin/iadmin mkresc dciResc 'unixfilesystem' valley.test.noao.edu:${vault}",
  require => Package['irods-icommands'],
  user    => 'testuser',
  } 


#! Don't need to copy this file in if we are running iinit
#!file { '/home/testuser/.irods/.irodsA':
#!  owner   => 'testuser',
#!  group   => 'testuser',
#!  source  => '/vagrant/irodsA',
#!  } ->


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
python::requirements { '/vagrant/requirements.txt': } ->

# Get from github now. But its in PyPI for when things stabalize!!!
python::pip {'daflsim':
  pkgname => 'daflsim',
  url     => 'https://github.com/pothiers/daflsim/archive/master.zip',
}
