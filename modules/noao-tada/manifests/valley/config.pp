class tada::valley::config (
  $secrets      = '/etc/rsyncd.scr',
  $icmdpath     = '/usr/local/share/applications/irods3.3.1/iRODS/clients/icommands/bin',
  $confdir      = hiera('tada_confdir'),
  $logging_conf = hiera('tada_logging_conf'),

  ) {
    ##############################################################################
  ### rsync
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
  
  firewall { '000 allow rsync':
    chain   => 'INPUT',
    state   => ['NEW'],
    dport   => '873',
    proto   => 'tcp',
    action  => 'accept',
  }
  ####
  ## Irods
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

  }
