class tada::valley::config (
  $secrets      = '/etc/rsyncd.scr',
  $icmdpath     = '/usr/local/share/applications/irods3.3.1/iRODS/clients/icommands/bin',
  $logging_conf = hiera('tada_logging_conf'),
  $irodsdata    = hiera('irodsdata'),
  $irodsenv     = hiera('irodsenv'),

  ) {
  
  file { [ '/var/tada/mountain-mirror', '/var/tada/noarchive']:
    ensure => 'directory',
    owner  => 'tada',
    mode   => '0744',
    #!mode   => '0777', #!!! tighten up permissions after initial burn in period
  }

  firewall { '000 allow dqsvcpop':
    chain   => 'INPUT',
    state   => ['NEW'],
    dport   => '6379',
    proto   => 'tcp',
    action  => 'accept',
  }
  

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
    source => "$irodsenv",
    }
  file { '/home/tada/.irods/iinit.in':
    owner  => 'tada',
    source => "$irodsdata",
  }
  exec { 'iinit':
    environment => ['irodsEnvFile=/home/tada/.irods/.irodsEnv',
                   'HOME=/home/tada' ],
    command     => "${icmdpath}/iinit `cat /home/tada/.irods/iinit.in`",
    user        => 'tada',
    creates     => '/home/tada/.irods/.irodsA',
    require     => [Exec['unpack irods'],
                    File[ '/home/tada/.irods/.irodsEnv',
                          '/home/tada/.irods/iinit.in']],
  }

  ###
  # CUPS (client only)
  file { '/etc/cups/client.conf':
    source  => "${confdir}/client.conf",
  } 


  }
