
if versioncmp($::puppetversion,'3.6.1') >= 0 {
  Package { allow_virtual => true, }
}

node default {
  notify {"DBG: site.pp; default":}
  class {'tada': }
}

node mountain {
  include tada
  include tada::mountain
}

node valley {
  include tada
  include tada::valley
}
