
notify {"DBG: client loading modules/profile/manifests/tada.pp":}

class profile::tada {
#!  class { 'tada':
#!    require     => [Class['gcc'],
#!                    Class['redis'],
#!                    ],
#!  }
}
