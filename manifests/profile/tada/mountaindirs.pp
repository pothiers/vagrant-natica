class sdm::profile::tada::mountaindirs {
  file { '/var/tada/mountain_cache':
    ensure => 'directory',
    mode   => '0777',
    owner  => 'tada',
  }
}


