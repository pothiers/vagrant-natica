# Intended for provisioning of: valley (archive)
#
# after: vagrant ssh
# sudo puppet apply --modulepath=/vagrant/modules /vagrant/manifests/init.pp --noop --graph
# sudo cp -r /var/lib/puppet/state/graphs/ /vagrant/

#! if versioncmp($::puppetversion,'3.6.1') >= 0 {
#!  $allow_virtual_packages = hiera('allow_virtual_packages',false)
  $allow_virtual_packages = false
  Package {
    allow_virtual => $allow_virtual_packages,
  }
#! }

include augeas
#
# epel is not needed by the puppet redis module but it's nice to have it
# already configured in the box
include epel

#!include rsync::server
#!class { 'rsync::server':
#!  motd_file => '/etc/rsync-motd',
#!}


#!service { 'xinetd':
#!  ensure  => 'running',
#!  enable  => true,
#!  require => [Package['xinetd'], File[ '/etc/rsyncd.conf']],
#!  } 

#!class { 'rsync': package_ensure => 'latest' }
$mirror='/var/tada/mountain-mirror'
$secrets='/etc/rsyncd.scr'
#!rsync::server::module{ 'repo':
#!  path            => $mirror,
#!  require         => File[$mirror, $secrets],
#!  read_only       => no,
#!  list            => yes,
#!  comment         => 'For transfer from Mountain to Valley',
#!  hosts_allow     => ['172.16.1.11',],
#!  auth_users      => ['vagrant', 'tada'],
#!  secrets_file    => $secrets,
#!  max_connections => 5,
#!}

file {  $mirror:
  ensure => 'directory',
  mode   => '0777',
  } 
file {  $secrets:
  source => '/sandbox/demo/conf/rsyncd.scr',
  mode   => '0400',
}

file {  '/etc/rsyncd.conf':
  source => '/sandbox/demo/conf/rsyncd.conf',
  mode   => '0400',
}


#! package { [ 'emacs', 'xorg-x11-xauth', 'wireshark-gnome', 'openssl-devel', 'expat-devel', 'perl-CPAN', 'libxml2-devel'] : }  # DBG
package { ['cups', 'xinetd'] : } 

#!class {'cpan':
#!  manage_package => false,
#!  #!installdirs => 'vendor',
#!  #!installdirs => 'perl',
#!  #!manage_config => 'false',
#!}



user { 'tada' :
  ensure     => 'present',
  comment    => 'For running TADA related services and actions',
  managehome => true, 
  password   => '$1$Pk1b6yel$tPE2h9vxYE248CoGKfhR41',  # tada"Password"
  system     => true,  
}

user { 'testuser' :
  ensure     => 'present',
  managehome => true,
  password   => '$1$4jJ0.K0P$eyUInImhwKruYp4G/v2Wm1',
  }


class { 'redis':
  #!version           => '2.8.13',
  version           => '2.8.19',
  redis_max_memory  => '1gb',
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
file {  '/etc/tada':
  ensure => 'directory',
  mode   => '0644',
  } ->
file {  '/etc/tada/tada.conf':
  source => '/sandbox/tada/conf/tada_config.json',
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
file { '/etc/cups/client.conf':
  source  => '/sandbox/demo/conf/client.conf',
} ->
service { 'cups':
  ensure  => 'running',
  enable  => true,
  require => Package['cups'],
  } 

# Get from github now. But its in PyPI for when things stabalize!!!
#!python::pip {'daflsim':
#!  pkgname => 'daflsim',
#!  url     => 'https://github.com/pothiers/daflsim/archive/master.zip',
#!}



#!exec { 'cpan':
#!  #!command => '/usr/bin/cpan -fi App::cpanminus',
#!  command => '/usr/bin/cpan App::cpanminus',
#!  require => Package['perl-CPAN'],
#!  timeout => 0,  # no timeout
#!  } ->
#!exec { 'cpanm':
#!  command => '/usr/local/bin/cpanm SOAP::Lite XML::XPath --force',
#!  timeout => 0, # no timeout
#!}





########################################################################
# iRODS has too many time consuming obstacles. Very hard to figure out #
# what goes wrong because error codes are often useless and            #
# documentation is out of date. THEREFORE, remove use of it from TADA  #
# proper. IRODS 3.3.1 is used by Archive Ingest, so we the icommands   #
# for that (which are incomopatible with icommands for 4.0.3)          #
########################################################################
###
file { '/usr/local/share/applications/irods-3.3.1.tgz':
  ensure => present,
  source => '/vagrant/valley/files/irods-3.3.1.tgz',
  notify => Exec['unpack irods'],
} 
exec { 'unpack irods':
  command     => '/bin/tar -xf /usr/local/share/applications/irods-3.3.1.tgz',
  cwd         => '/usr/local/share/applications',
  refreshonly => true,
}

#$irodsbase = 'ftp://ftp.renci.org/pub/irods/releases/4.0.3'
#package { ['fuse-libs','openssl098e']: } ->
#package { 'irods-icommands':
#  provider => 'rpm',
#  source   => "${irodsbase}/irods-icommands-4.0.3-64bit-centos6.rpm",
#} 
#$vault='/var/lib/irods/iRODS/dciVault'
#file { '/home/tada/.irods':
#  ensure  => 'directory',
#  owner   => 'tada',
#  require => User['tada'],
#  } ->
#file { '/home/tada/.irods/.irodsEnv':
#  owner   => 'tada',
#  source  => '/vagrant/mountain/files/irodsEnv',
#  } ->
#exec { 'irod-iinit':
#  environment => ['HOME=/home/tada'],
#  command     => '/usr/bin/iinit temppasswd',
#  require     => Package['irods-icommands'],
#  user        => 'tada',
#}
#!->
#!#exec { 'irod-resource':
#!#  environment => ['HOME=/home/tadauser'],
#!#  command     => "/usr/bin/iadmin mkresc dciResc 'unixfilesystem' valley.test.noao.edu:${vault}",
#!#  require     => Package['irods-icommands'],
#!#  user        => 'tadauser',
#!#  }
###
#######################################################################

