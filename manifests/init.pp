include augeas
# epel is not needed by the puppet redis module but it's nice to have it
# already configured in the box
include epel

Class['epel'] -> Package<||>{ provider => 'yum' }

class { 'redis':
  version        => '2.8.13',
  redis_password => 'test',
}
