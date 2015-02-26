# Intended for provisioning of: mountain


# Following is attempt to get around the warning:
#   "Warning: The package type's allow_virtual parameter will be
#   changing its default value from false to true in a future
#   release. If you do not want to allow virtual packages, please
#   explicitly set allow_virtual to false.
#      (at /usr/lib/ruby/site_ruby/1.8/puppet/type/package.rb:430:in `default')"
# But it doesn't work!!! (at least when this is run from vagrant)  Sigh.
Package {
  allow_virtual => false,
}



# epel is not needed by the puppet redis module but it's nice to have it
# already configured in the box
# (epel:: Extra Repository for Enterprise Linux)
include epel
include augeas

yumrepo { 'ius':
  descr      => 'ius - stable',
  baseurl    => 'http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/',
  enabled    => 1,
  gpgcheck   => 0,
  priority   => 1,
  mirrorlist => absent,
} -> Package<| provider == 'yum' |>


#!package { ['emacs', 'xorg-x11-xauth', 'telnet'] : }  # DBG
package { ['cups'] : }

user { 'tada' :
  ensure     => 'present',
  comment    => 'For running TADA related services and actions',
  managehome => true, # comment out after debugging
  password   => '$1$Pk1b6yel$tPE2h9vxYE248CoGKfhR41',  # tada"Password"
  system     => true,  
}
user { 'testuser' :
  ensure     => 'present',
  comment    => 'Normal user for for testing TADA',
  managehome => true,
  password   => '$1$4jJ0.K0P$eyUInImhwKruYp4G/v2Wm1',
}



##############################################################################
# Setup for installing python packages
#
class { 'python':
  version    => '34u',
  pip        => false,
  dev        => true,
  virtualenv => true,
} 
package { 'python34u-pip': } 
file { '/usr/bin/pip':
  ensure => 'link',
  target => '/usr/bin/pip3.4',
} 
python::requirements { '/vagrant/requirements.txt': } 
Class['python'] -> Package['python34u-pip'] -> File['/usr/bin/pip']
  -> Python::Requirements['/vagrant/requirements.txt']

#! $confdir='/sandbox/tada/conf'
$confdir='/sandbox/demo/conf'

##############################################################################
### Configure TADA  (move to config.pp!!!)
###
file {  '/etc/tada':
  ensure => 'directory',
}
file {  [ '/var/run/tada', '/var/log/tada']:
  ensure => 'directory',
  owner  => 'tada',
  mode   => '0744',
}
file {  '/etc/tada/tada.conf':
  source => "${confdir}/tada_config.json",
  #!mode   => '0744',
}
file { '/etc/tada/pop.yaml':
  source => "${confdir}/tada-logging.yaml",
  #!mode   => '0744',
  }
###  
##############################################################################


##############################################################################
### Install TADA  (move to install.pp!!!)
###
class { 'redis':
  version           => '2.8.19',
  redis_max_memory  => '1gb',
}
#!exec { 'dataq':
#!  command => '/usr/bin/python3 /sandbox/data-queue/setup.py install',
#!  #!  require => Python::requirements['/vagrant/requirements.txt']
#!  require => Package['python34u-pip']
#!}
#!python::pip {'dataq':
#!  require       => Python::Requirements['/vagrant/requirements.txt'],
#!  pkgname       => 'dataq',
#!  ensure        => 'latest',
#!  #!url         => 'git+git@github.com:pothiers/data-queue.git#egg=dataq',
#!  url           => 'file://sandbox/data-queue',
#!  install_args  => ['--pre', '--upgrade',
#!                    #!'--no-index',
#!                    #!'--find-links=/sandbox/data-queue',
#!                    ],
#!} ->
#!python::pip {'tada':
#!  require       => Python::Requirements['/vagrant/requirements.txt'],
#!  pkgname       => 'dataq',
#!  ensure        => 'latest',
#!  #!url         => 'git+git@github.com:pothiers/data-queue.git#egg=dataq',
#!  #!url           => '/sandbox/data-queue',
#!  install_args  => ['--pre', '--upgrade', '--no-index',
#!                    '--find-links=/sandbox/tada'],
#!} ->
#!notify { 'tada_done':
#!  message => "python DATAQ and TADA installed",
#!}

##########################################
# TADA services.
# Would be nice to SUBSCRIBE to the dependencies, and restart services
# upon any change to dependency. Gotta make dqsvc be restartable
# service (in the puppet sense) for that to work!!!
$qname = hiera('queuename')
$dqlevel = hiera('dq_loglevel')
exec { 'dqsvcpush':
  command     => "/usr/bin/dqsvcpush --loglevel ${dqlevel} --queue ${qname} > /var/log/tada/dqpush.log 2>&1 &",
  user        => 'tada',
  refreshonly => true,
  creates     => '/var/run/tada/dqsvcpush.pid',
  require     => [File['/var/run/tada'], Class['redis']],
  subscribe   => [File['/etc/tada/tada.conf'],
                  Python::Requirements[ '/vagrant/requirements.txt'],
                  #!Python::Pip['dataq'],
                  ],
}
exec { 'dqsvcpop':
  command     => "/usr/bin/dqsvcpop --loglevel ${dqlevel} --queue ${qname} > /var/log/tada/dqpop.log 2>&1 &",
  user        => 'tada',
  creates     => '/var/run/tada/dqsvcpop.pid',
  refreshonly => true,
  require     => [File['/var/run/tada'], Class['redis']],
  subscribe   => [File['/etc/tada/tada.conf'],
                  Python::Requirements[ '/vagrant/requirements.txt'],
                  #!Python::Pip['dataq'],
                  ],
}
###  
##############################################################################



##############################################################################
### Install astro  (move to install.pp!!!  this is mix of install/config)
###
# ASTRO
$astroprinter='astro'
$mountaincache='/var/tada/mountain_cache'
file {  ['/usr/lib/cups',
         '/usr/lib/cups/lib',
         '/usr/lib/cups/lib/astro',
         '/usr/lib/cups/backend']:
  ensure => directory,
  } 
file { '/etc/cups/cupsd.conf':
  source => '/vagrant/mountain/files/new-cupsd.conf'
  } 
file {  '/usr/lib/cups/lib/astro/pushfile.sh':
  source => '/sandbox/tada/astro/pushfile.sh',
  mode   => '0555',
  owner  => 'tada',
  } 
file {  '/usr/lib/cups/backend/astropost':
  source => '/sandbox/tada/astro/astropost',
  mode   => '0700',
  owner  => 'root',
  } 
service { 'cups':
  ensure  => 'running',
  enable  => true,
  require => Package['cups'],
  subscribe => File['/etc/cups/cupsd.conf',
                    '/usr/lib/cups/lib/astro/pushfile.sh',
                    '/usr/lib/cups/backend/astropost'],
  } 
  
exec { 'add-astro-printer':
  command => "/usr/sbin/lpadmin -p ${astroprinter} -v astropost:${mountaincache} -E",
  subscribe => Service['cups'],
  }

file { ['/var/tada', $mountaincache] :
  ensure => 'directory',
  mode   => '0777',
  owner  => 'tada',
  }
  
file { '/etc/tada/rsync.pwd':
  source => "${confdir}/rsync.pwd",
  mode   => '0400',
  owner  => 'tada',
  } 
###  
##############################################################################


  

########################################################################
# iRODS has too many time consuming obstacles. Very hard to figure out #
# what goes wrong because error codes are often useless and            #
# documentation is out of date. THEREFORE, remove use of it from TADA. #
########################################################################
###
#! $irodsbase = 'ftp://ftp.renci.org/pub/irods/releases/4.0.3'
#! package { ['fuse-libs','openssl098e']: } ->
#! package { 'irods-icommands':
#!   provider => 'rpm',
#!   source   => "${irodsbase}/irods-icommands-4.0.3-64bit-centos6.rpm",
#!   } 
#! $vault='/var/lib/irods/iRODS/dciVault'
#! file { '/home/tadauser/.irods':
#!   ensure  => 'directory',
#!   owner   => 'tadauser',
#!   group   => 'tadauser',
#!   require => User['tadauser'],
#!   } ->
#! file { '/home/tadauser/.irods/.irodsEnv':
#!   owner   => 'tadauser',
#!   group   => 'tadauser',
#!   source  => '/vagrant/mountain/files/irodsEnv',
#!   } ->
#! exec { 'irod-iinit':
#!   environment => ['HOME=/home/tadauser'],
#!   command     => '/usr/bin/iinit temppasswd',
#!   require     => Package['irods-icommands'],
#!   user        => 'tadauser',
#! }
#!->
#!#exec { 'irod-resource':
#!#  environment => ['HOME=/home/tadauser'],
#!#  command     => "/usr/bin/iadmin mkresc dciResc 'unixfilesystem' valley.test.noao.edu:${vault}",
#!#  require     => Package['irods-icommands'],
#!#  user        => 'tadauser',
#!#  }
###
#######################################################################

