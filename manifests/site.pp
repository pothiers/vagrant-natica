node default {
  notify {"DBG: site.pp; default":}
  class {'tada': }
}

node mountain {
  notify {"DBG: site.pp; mountain.test.noao.edu":}
  include tada
  include tada::mountain
}

node valley {
  notify {"DBG: site.pp; valley.test.noao.edu":}
  include tada
  include tada::valley
}
