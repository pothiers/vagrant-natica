
########################################################################
# iRODS (4.0.3) has too many time consuming obstacles. Very hard to    #
# figure out what goes wrong because error codes are often useless and #
# documentation is out of date. THEREFORE, remove use of it from TADA  #
# proper. IRODS 3.3.1 is used by Archive Ingest, so we the icommands   #
# for that (which are incomopatible with icommands for 4.0.3)          #
# -pothier-
########################################################################

class sdm::profile::tada::icommands {
  $confdir="puppet:///modules/sdm" # => /etc/puppet/modules/sdm
  $tarball='/usr/local/share/applications/irods-3.3.1.tgz'
  $irodsdata="puppet:///modules/sdm/iinit.in" 
  $irodsenv="puppet:///modules/sdm/irodsEnv" 

  file { "$tarball":
    ensure => present,
    source => "$confdir/irods-3.3.1.tgz",
    notify => Exec['unpack irods'],
  } 
  exec { 'unpack irods':
    command     => "/bin/tar -xf $tarball",
    cwd         => '/usr/local/share/applications',
    refreshonly => true,
  }
  file { '/home/tada/.irods':
    ensure => 'directory',
    owner  => 'tada',
  }
  file { '/home/tada/.irods/.irodsEnv':
    owner  => 'tada',
    source => "$irodsenv"
  }
  file { '/home/tada/.irods/iinit.in':
    owner  => 'tada',
    source => "$irodsdata",
  }
  $icmdpath='/usr/local/share/applications/irods3.3.1/iRODS/clients/icommands/bin'
  exec { 'iinit':
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
