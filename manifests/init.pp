include augeas
# epel is not needed by the puppet redis module but it's nice to have it
# already configured in the box
include epel

Class['epel'] -> Package<||>{ provider => 'yum' }

class { 'redis':
  version        => '2.8.13',
  redis_password => 'test',
}


#! class { 'graphite': }


yumrepo { 'ius':
  descr      => 'ius - stable',
  baseurl    => 'http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/',
  enabled    => 1,
  gpgcheck   => 0,
  priority   => 1,
  mirrorlist => absent,
} -> Package<| provider == 'yum' |>


#!class { 'python':    
#!  version    => '3.4.1',
#!  pip        => true,
#!  dev        => true,
#!  virtualenv => true,
#!  gunicorn   => false,
#!}

class { 'python':
  version    => '34u',
  pip        => false,
  dev        => true,
  virtualenv => true,
}



package { 'python34u-pip': } ->
file { '/usr/bin/pip':
  ensure => 'link',
  target => '/usr/bin/pip3.4',
} ->


package { 'graphviz-devel': } ->




python::requirements { '/vagrant/requirements.txt': }
