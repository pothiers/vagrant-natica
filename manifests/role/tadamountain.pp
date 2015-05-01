class sdm::role::tadamountain {
  $vers=1
  notify {"DBG: client loading role::tadamountain STUB-$vers":}
  #!include ::sdm::profile::base
  include ::sdm::profile::rsync::client
  include ::sdm::profile::cups::server
  include ::sdm::profile::tada::common
  include ::sdm::profile::tada::mountaindirs
  include ::sdm::profile::tada::astro
}
