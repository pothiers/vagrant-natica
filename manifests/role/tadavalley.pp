class sdm::role::tadavalley {
  $vers=1
  notify {"DBG: client loading role::tadavalley STUB-$vers}":}
  #!include ::sdm::profile::base
  #!include ::sdm::site::tu
  
  include ::sdm::profile::rsync::server
  include ::sdm::profile::cups::client
  include ::sdm::profile::tada::common
  include ::sdm::profile::tada::valleydirs
  include ::sdm::profile::tada::icommands
}
