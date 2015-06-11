
notify {"DBG: client loading manifests/profile/tada.pp":}

class profile::tada {
  class { '::tada':
    require     => [Class['gcc'],
                    Class['redis'],
                    ],
  }
}
