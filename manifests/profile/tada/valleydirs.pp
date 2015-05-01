class sdm::profile::tada::valleydirs {
  file { [ '/var/tada/mountain-mirror', '/var/tada/noarchive']:
    ensure => 'directory',
    owner  => 'tada',
    #!mode   => '0744',
    mode   => '0777', #!!! tighten up permissions after initial burn in period
  }

}

