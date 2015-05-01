class sdm::profile::rsync::server {
  $confdir="puppet:///modules/sdm" # => /etc/puppet/modules/sdm
  $secrets='/etc/rsyncd.scr'  # !!!

  package { ['xinetd'] : }   
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
  
}
