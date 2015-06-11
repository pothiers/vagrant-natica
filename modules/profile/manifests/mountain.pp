notify {"DBG: loading modules/profile/manifests/mountain.pp":}
class tada::mountain (
  $mtncache    =  '/var/tada/mountain_cache',
  ) {
  file { $mtncache:
    ensure => 'directory',
    mode   => '0777',
    owner  => 'tada',
  }
}
