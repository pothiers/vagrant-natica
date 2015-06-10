# Resources related to configuring the installed software 
# https://docs.puppetlabs.com/guides/module_guides/bgtm.html

class tada::mountain::config (

  $cupsdconf       = hiera('cupsdconf'),
  $pushfilesh      = hiera('pushfilesh'),
  $astropost       = hiera('astropost'),
  $rsyncpwd        = hiera('rsyncpwd'),
  $mtncache        = hiera('mtncache', '/var/tada/mountain_cache'),
  ) {

  file { "$mtncache":
    ensure => 'directory',
    mode   => '0777',
    owner  => 'tada',
  }

  firewall { '631 allow cups':
    chain   => 'INPUT',
    state   => ['NEW'],
    dport   => '631',
    proto   => 'tcp',
    action  => 'accept',
  }
  

  ###########################################################################
  ### astro 
  ###
  file {  ['/usr/lib/cups',
           '/usr/lib/cups/lib',
           '/usr/lib/cups/lib/astro',
           '/usr/lib/cups/backend']:
             ensure => directory,
  } 
  file { '/etc/cups/cupsd.conf':
    source => "$cupsdconf" ,
  } 
  file {  '/usr/lib/cups/lib/astro/pushfile.sh':
    source => "$pushfilesh",
    mode   => '0555',
    owner  => 'tada',
  } 
  file {  '/usr/lib/cups/backend/astropost':
    source => $astropost, 
    mode   => '0700',
    owner  => 'root',
  } 

  #################
  file { '/etc/tada/rsync.pwd':
    source => "$rsyncpwd", 
    mode   => '0400',
    owner  => 'tada',
  } 

  
  }
