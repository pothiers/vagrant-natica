# Role for any TADA Mountain machine

notify {"DBG: loading modules/role/manifests/tadamountain.pp":}

class role::tadamountain {
  notify {"DBG: loading role::tadamountain STUB":}
  #!include ::sdm::profile::base

  #include ::profile::rsync::client
  #include ::profile::cups::server
  include ::profile::tada
  #include ::tada::mountain
  #include ::profile::tada::astro
}



