# Role for any TADA Valley machine

notify {"DBG: loading modules/role/manifests/tadavalley.pp":}

class role::tadavalley {
  notify {"DBG: loading role::tadavalley STUB}":}
  #!include ::sdm::profile::base
  #!include ::sdm::site::tu
  
  #include ::sdm::profile::rsync::server
  #include ::sdm::profile::cups::client
  include ::profile::tada
  #include ::sdm::profile::tada::valleydirs
  #include ::sdm::profile::tada::icommands
}
