class sdm::profile::cups::server {
  $confdir="puppet:///modules/sdm" # => /etc/puppet/modules/sdm
  
  package { ['cups'] : }
  file {  ['/usr/lib/cups', '/usr/lib/cups/lib', '/usr/lib/cups/lib/astro',
           '/usr/lib/cups/backend']:
             ensure => directory,
  } 
  file { '/etc/cups/cupsd.conf':
    source => "$confdir/new-cupsd.conf"
  } 
  service { 'cups':
    ensure  => 'running',
    enable  => true,
    require => Package['cups'],
    subscribe => File['/etc/cups/cupsd.conf',
                      '/usr/lib/cups/lib/astro/pushfile.sh',
                      '/usr/lib/cups/backend/astropost'],
  } 
}
