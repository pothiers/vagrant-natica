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
#
# epel is not needed by the puppet redis module but it's nice to have it
# already configured in the box
include epel

package { ['emacs', 'xorg-x11-xauth', 'cups',
           #! 'wireshark-gnome',
           'openssl-devel', 'expat-devel', 'perl-CPAN', 'libxml2-devel'] : } 
#!class {'cpan':
#!  manage_package => false,
#!  #!installdirs => 'vendor',
#!  #!installdirs => 'perl',
#!  #!manage_config => 'false',
#!}



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
  #!version           => '2.8.13',
  version           => '2.8.19',
  redis_max_memory  => '1gb',
}

class { 'irods':
  #!!! Want this to be relative ('../modules/irods/files/setup_irods.input')
  #!!! How?
  setup_input_file => '/vagrant/valley/modules/irods/files/setup_irods.input',
}

#!package { 'irods-icommands':
#!  provider => 'rpm',
#!  source   => "${irodsbase}/irods-icommands-4.0.3-64bit-centos6.rpm",
#!  require  => Package['fuse-libs','openssl098e'],
#!  } 


$vault='/var/lib/irods/iRODS/tadaVault'
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
  require     => [Package['irods-icommands'], Class['irods']],
  user        => 'tadauser',
  } ->
exec { 'irod-resource':
  environment => ['HOME=/home/tadauser'],
  command     => "/usr/bin/iadmin mkresc tadaResc 'unixfilesystem' valley.test.noao.edu:${vault}",
  require     => Package['irods-icommands'],
  user        => 'tadauser',
  } ->
#!exec { 'irod-resource':
#!  environment => ['HOME=/home/tadauser'],
#iadmin!  command     => "/usr/bin/iadmin mkzone noao-tuc-z1 remote",
#!  require     => Package['irods-icommands'],
#!  user        => 'tadauser',
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
python::requirements { '/vagrant/requirements.txt': } 

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
  command => '/usr/bin/dqsvcpush > /var/log/tada/push.log 2>&1 &',
  require => File['/var/run/tada'],
}
exec { 'dqsvcpop':
  command => '/usr/bin/dqsvcpop > /var/log/tada/pop.log 2>&1 &',
  require => File['/var/run/tada'],
}


# ASTRO
$astroprinter='astro'
service { 'cups':
  ensure  => 'running',
  enable  => true,
  require => Package['cups'],
  } ->
file { '/etc/cups/client.conf':
  source  => '/vagrant/client.conf',
}
#!->
#!exec { 'add-astro-printer':
#!  command => "/usr/sbin/lpadmin -p ${astroprinter} -v astropost:${mountaincache} -E",
#!  }



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




#!cpan { "App::cpanminus":
#!  ensure  => present,
#!  require => Class['::cpan'],
#!  } ->
exec { 'cpan':
  #!command => '/usr/bin/cpan -fi App::cpanminus',
  command => '/usr/bin/cpan App::cpanminus',
  require => Package['perl-CPAN'],
  timeout => 0,  # no timeout
  } ->
exec { 'cpanm':
  command => '/usr/local/bin/cpanm SOAP::Lite XML::XPath --force',
  timeout => 0, # no timeout
}



# see "Installing Additional Clients" in https://wiki.irods.org/index.php/Installation
