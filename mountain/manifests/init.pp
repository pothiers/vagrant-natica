# Intended for provisioning of: mountain

# epel is not needed by the puppet redis module but it's nice to have it
# already configured in the box
# (epel:: Extra Repository for Enterprise Linux)
include epel
include augeas

#!package { ['emacs', 'xorg-x11-xauth', 'telnet'] : }  # DBG
package { ['cups', 'git'] : }

#! $confdir='/sandbox/tada/conf'
$confdir=hiera('tada_confdir')
$logging_conf=hiera('tada_logging_conf')
$tada_conf=hiera('tada_conf')

##############################################################################
# Setup for installing python packages
#
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
} 
package { 'python34u-pip': } 
file { '/usr/bin/pip':
  ensure => 'link',
  target => '/usr/bin/pip3.4',
} 
python::requirements { '/vagrant/requirements.txt': } 
Class['python'] -> Package['python34u-pip'] -> File['/usr/bin/pip']
  -> Python::Requirements['/vagrant/requirements.txt']

##############################################################################
class { 'redis':
  version           => '2.8.19',
  redis_max_memory  => '1gb',
}

##############################################################################
### Configure TADA  (move to config.pp!!!)
###
user { 'tada' :
  ensure     => 'present',
  comment    => 'For running TADA related services and actions',
  managehome => true, # comment out after debugging
  password   => '$1$Pk1b6yel$tPE2h9vxYE248CoGKfhR41',  # tada"Password"
  system     => true,  
}

file { [ '/var/run/tada', '/var/log/tada', '/etc/tada',
         '/var/tada', '/var/tada/mountain-mirror', '/var/tada/noarchive']:
  ensure => 'directory',
  owner  => 'tada',
  #!mode   => '0744',
  mode   => '0777', #!!! tighten up permissions after initial burn in period
}

file {  '/etc/tada/tada.conf':
  source => "${tada_conf}",
  #! mode   => '0744',
}
file { '/etc/tada/pop.yaml':
  source => "${logging_conf}",
  #! mode   => '0744',
}
file { '/var/log/tada/submit.manifest':
  ensure => 'file',
  owner  => 'tada',
  mode   => '0744',
}

exec { 'dqsvcpop':
  command     => "/usr/bin/dqsvcpop --loglevel ${dqlevel} --queue ${qname} > /var/log/tada/dqpop.log 2>&1 &",
  user        => 'tada',
  creates     => '/var/run/tada/dqsvcpop.pid',
  refreshonly => true,
  require     => [File['/var/run/tada'], Class['redis']],
  subscribe   => [File['/etc/tada/tada.conf'],
                  Python::Requirements[ '/vagrant/requirements.txt'],
                  ],
}

##############################################################################
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
#!exec { 'dqsvcpush':
#!  command     => "/usr/bin/dqsvcpush --loglevel ${dqlevel} --queue ${qname} > /var/log/tada/dqpush.log 2>&1 &",
#!  user        => 'tada',
#!  refreshonly => true,
#!  creates     => '/var/run/tada/dqsvcpush.pid',
#!  require     => [File['/var/run/tada'], Class['redis']],
#!  subscribe   => [File['/etc/tada/tada.conf'],
#!                  Python::Requirements[ '/vagrant/requirements.txt'],
#!                  #!Python::Pip['dataq'],
#!                  ],
#!}
###  
##############################################################################

firewall { '631 allow cups':
  chain   => 'INPUT',
  state   => ['NEW'],
  dport   => '631',
  proto   => 'tcp',
  action  => 'accept',
}


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

  
file { '/etc/tada/rsync.pwd':
  source => "${confdir}/rsync.pwd",
  mode   => '0400',
  owner  => 'tada',
  } 
###  
##############################################################################


