# Role for any TADA Mountain machine

class role::tadamountain () {
  $vers=2
  notify {"DBG: client loading role::tadamountain STUB-$vers":}
  #!include ::sdm::profile::base
  include ::tada::profile::rsync::client
  include ::tada::profile::cups::server
  include ::tada::profile::tada::common
  include ::tada::profile::tada::mountaindirs
  include ::tada::profile::tada::astro
}
