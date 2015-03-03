# Intended for provisioning of: valley (archive)
#
# after: vagrant ssh
# sudo puppet apply --modulepath=/vagrant/modules /vagrant/manifests/init.pp --noop --graphsub
# sudo cp -r /var/lib/puppet/state/graphs/ /vagrant/


include epel
include augeas

#! package { [ 'emacs', 'xorg-x11-xauth', 'wireshark-gnome', 'openssl-devel', 'expat-devel', 'perl-CPAN', 'libxml2-devel'] : }  # DBG
package { ['cups', 'xinetd'] : } 

#! $confdir='/sandbox/tada/conf'
#! $confdir='/sandbox/demo/conf'
$confdir=hiera('tada_confdir')


##############################################################################
### rsync
$secrets='/etc/rsyncd.scr'
file {  $secrets:
  source => "${confdir}/rsyncd.scr",
  owner  => 'root',
  mode   => '0400',
}
file {  '/etc/rsyncd.conf':
  source => "${confdir}/rsyncd.conf",
  owner  => 'root',
  mode   => '0400',
}
exec { 'rsyncd':
  command   => "/sbin/chkconfig rsync on",
  require   => [Service['xinetd'],],
  subscribe => File['/etc/rsyncd.conf'],
}
service { 'xinetd':
  ensure  => 'running',
  enable  => true,
  require => Package['xinetd'],
  }


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


file { '/etc/cups/client.conf':
  source  => "${confdir}/client.conf",
} 
service { 'cups':
  ensure  => 'running',
  enable  => true,
  require => Package['cups'],
  subscribe => File['/etc/cups/client.conf'],
  } 


##############################################################################
### Configure TADA  (move to config.pp!!!)
###
#!file {  '/etc/tada':
#!  ensure => 'directory',
#!}
file { [ '/var/run/tada', '/var/log/tada', '/etc/tada',
         '/var/tada', '/var/tada/mountain-mirror', '/var/tada/noarchive']:
  ensure => 'directory',
  owner  => 'tada',
  #!mode   => '0744',
  mode   => '0777', #!!! tighten up permissions after initial burn in period
}

file {  '/etc/tada/tada.conf':
  source => "${confdir}/tada_config.json",
  #! mode   => '0744',
}
file { '/etc/tada/pop.yaml':
  source => "${confdir}/tada-logging.yaml",
  #! mode   => '0744',
}


###  
##############################################################################

  
#!file {  '/etc/tada':
#!  ensure => 'directory',
#!  mode   => '0644',
#!  } ->
#!file {  '/etc/tada/tada.conf':
#!  source => '/sandbox/tada/conf/tada_config.json',
#!  mode   => '0744',
#!  } ->
#!file {  '/var/run/tada':
#!  ensure => 'directory',
#!  mode   => '0777',
#!  } ->
#!file {  '/var/log/tada':
#!  ensure => 'directory',
#!  mode   => '0777',
#!}
#!file {  '/var/tada':
#!  ensure => 'directory',
#!  mode   => '0777',
#!}

#!!exec { 'dataq':
#!!  command => '/usr/bin/python3 /sandbox/data-queue/setup.py install',
#!!  #!  require => Python::requirements['/vagrant/requirements.txt']
#!!  require => Package['python34u-pip']
#!!  } 




##########################################
# TADA services.
# Would be nice to SUBSCRIBE to the dependencies, and restart services
# upon any change to dependency. Gotta make dqsvc be restartable
# service (in the puppet sense) for that to work!!!

#!exec { 'dqsvcpush':
#!  command => '/usr/bin/dqsvcpush > /var/log/tada/push.log 2>&1 &',
#!  require => File['/var/run/tada'],
#!}
#!exec { 'dqsvcpop':
#!  command => '/usr/bin/dqsvcpop > /var/log/tada/pop.log 2>&1 &',
#!  require => File['/var/run/tada'],
#!}

$qname = hiera('queuename')
$dqlevel = hiera('dq_loglevel')
exec { 'dqsvcpush':
  command     => "/usr/bin/dqsvcpush --loglevel ${dqlevel} --queue ${qname} > /var/log/tada/dqpush.log 2>&1 &",
  user        => 'tada',
  environment => ['HOME=/home/tada'],
  #! refreshonly => true,
  creates     => '/var/run/tada/dqsvcpush.pid',
  require     => [File['/etc/tada/tada.conf',
                       '/var/run/tada',
                       '/home/tada/.irods/.irodsEnv'],
                  Python::Requirements[ '/vagrant/requirements.txt'],
                  Class['redis'],
                  ],
}
exec { 'dqsvcpop':
  command     => "/usr/bin/dqsvcpop --loglevel ${dqlevel} --queue ${qname} > /var/log/tada/dqpop.log 2>&1 &",
  user        => 'tada',
  environment => ['HOME=/home/tada'],
  creates     => '/var/run/tada/dqsvcpop.pid',
  #! refreshonly => true,
  require     => [File['/etc/tada/tada.conf',
                       '/var/run/tada',
                       '/home/tada/.irods/.irodsEnv'],
                  Python::Requirements[ '/vagrant/requirements.txt'],
                  Class['redis'],
                  ],
}
###  
##############################################################################



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
file { '/home/tada/.irods':
  ensure => 'directory',
  owner  => 'tada',
}
file { '/home/tada/.irods/.irodsEnv':
  owner  => 'tada',
  source => '/vagrant/valley/files/irodsEnv'
  }
file { '/home/tada/.irods/iinit.in':
  owner  => 'tada',
  source => hiera('irodsdata'),
}
$icmdpath='/usr/local/share/applications/irods3.3.1/iRODS/clients/icommands/bin'
exec { 'iinit':
  #!command     => "${icmdpath}/iinit `cat /home/tada/.irods/iinit.in`",
  environment => ['irodsEnvFile=/home/tada/.irods/.irodsEnv',
                 'HOME=/home/tada' ],
  command     => "${icmdpath}/iinit cacheMonet", #!!!
  user        => 'tada',
  creates     => '/home/tada/.irods/.irodsA',
  require     => [Exec['unpack irods'],
                  File[ '/home/tada/.irods/.irodsEnv',
                        '/home/tada/.irods/iinit.in']],
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

