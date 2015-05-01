class sdm::profile::cups::client {
  $confdir="puppet:///modules/sdm" # => /etc/puppet/modules/sdm

  package { ['cups'] : }
  
  file { '/etc/cups/client.conf':
    source  => "${confdir}/cups-client.conf",
  } 
  service { 'cups':
    ensure  => 'running',
    enable  => true,
    require => Package['cups'],
    subscribe => File['/etc/cups/client.conf'],
  }

}
