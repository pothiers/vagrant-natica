class sdm::profile::rsync::client {
  $confdir="puppet:///modules/sdm" # => /etc/puppet/modules/sdm
  file { '/etc/tada/rsync.pwd':
    source => "${confdir}/rsync.pwd",
    mode   => '0400',
    owner  => 'tada',
  }
}
  
