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


#!$iinit_input = '/vagrant/valley/modules/irods/files/iinit.input'
#!exec { "/usr/bin/iinit < ${iinit_input}":
#!  require => Package['irods-icommands'],
#!  user    => 'testuser',
#!}
$vault='/var/lib/irods/iRODS/Vault'
file { '/home/testuser/.irods':
  ensure  => 'directory',
  owner   => 'testuser',
  group   => 'testuser',
  require => User['testuser'],
  } ->
#!file { '/home/testuser/.irods/.irodsA':
#!  owner   => 'testuser',
#!  group   => 'testuser',
#!  source  => '/vagrant/irodsA',
#!  } ->
#!file { '/home/testuser/.irods/.irodsEnv':
#!  owner   => 'testuser',
#!  group   => 'testuser',
#!  source  => '/vagrant/irodsEnv',
#!  } 

##  ARG!!! Cannot seem to feed iinit via file so that it is happy. Do manual for now!!!  
#!exec { 'irod-iinit':
#!   command => "/usr/bin/iinit < /vagrant/iinit.input",
#!   require => Package['irods-icommands'],
#!   user    => 'testuser',
#!   } ->
#! exec { 'irod-resource':
#!   command => "/usr/bin/iadmin mkresc dciResc 'unixfilesystem' valley.test.noao.edu:${vault}",
#!   require => Package['irods-icommands'],
#!   user    => 'testuser',
#!   } 
  

# !!! The following yields rcConnect error from irods when run during provisioning.
#     "ERROR: _rcConnect: setRhostInfo error, irodsHost is probably not set correctly status = -302000 USER_RODS_HOST_EMPTY"
# Yet it works when typed in under testuser. But it prompts for password despite the .irodsA
# file being in place.
#
#!exec { 'irod-resource':
#!  command => "/usr/bin/iadmin mkresc dciResc 'unixfilesystem' valley.test.noao.edu:${vault}",
#!  require => Package['irods-icommands'],
#!  user    => 'testuser',
#!}
  
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


