class sdm::profile::tada::astro {
  include ::sdm::profile::cupsserver
  $confdir="puppet:///modules/sdm" # => /etc/puppet/modules/sdm
  $astroprinter='astro'
  
  file {  '/usr/lib/cups/lib/astro/pushfile.sh':
    source => "$confdir/pushfile.sh",
    mode   => '0555',
    owner  => 'tada',
  } 
  file {  '/usr/lib/cups/backend/astropost':
    source => "$confdir/astropost",
    mode   => '0700',
    owner  => 'root',
  } 
  exec { 'add-astro-printer':
    command => "/usr/sbin/lpadmin -p ${astroprinter} -v astropost:/var/tada/mountain_cache -E",
    subscribe => Service['cups'],
  }

}
