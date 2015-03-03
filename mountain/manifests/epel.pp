### UNDER CONSTRUCTION!!!

# (epel:: Extra Repository for Enterprise Linux)
include epel

class mountain::epel {
  yumrepo { 'epel':
    enabled => 1,
  }

  Yumrepo['epel'] -> Package <||>
}


yumrepo { 'ius':
  descr      => 'ius - stable',
  baseurl    => 'http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/',
  enabled    => 1,
  gpgcheck   => 0,
  priority   => 1,
  mirrorlist => absent,
}

Yumrepo ['-> Package<| provider == 'yum' |>
