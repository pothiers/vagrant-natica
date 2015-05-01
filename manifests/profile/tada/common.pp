# Resources common to all tada hosts (valleys, mountains)

class sdm::profile::tada::common () {
  $dqlevel="DEBUG"
  $confdir="puppet:///modules/sdm" # => /etc/puppet/modules/sdm
  $tadapyreq="$confdir/tada-requirements.txt"
  $qname=hiera('qname')
  $tadaversion=hiera('tadaversion')
  
  include gcc  # required by astropy python package
  include redis 

  notify {"DBG: client loading sdm::profile::tada::common; vers=$tadaversion":}
  notify {"DBG: client loading sdm::profile::tada::common; qname=$qname":}

  #!package { ['python34u-pip', 'python-devel', 'numpy']: } 
  package { ['python34u-pip']: } 
  
  user { 'tada' :
    ensure     => 'present',
    comment    => 'For running TADA related services and actions',
    managehome => true, 
    password   => '$1$Pk1b6yel$tPE2h9vxYE248CoGKfhR41',  # tada"Password"
    system     => true,  
  }
  file { [ '/var/run/tada', '/var/log/tada', '/etc/tada', '/var/tada']:
    ensure => 'directory',
    owner  => 'tada',
  }
  file {  '/etc/tada/tada.conf':
    source => "${confdir}/tada_config.json",
    #! mode   => '0744',
  }
  file { '/etc/tada/pop.yaml':
    source => "${confdir}/tada-logging.yaml",
    #! mode   => '0744',
  }
  file { '/var/log/tada/submit.manifest':
    ensure => 'file',
    owner  => 'tada',
    mode   => '0766',
  }
  
  yumrepo { 'ius':
    descr      => 'ius - stable',
    baseurl    => 'http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/',
    enabled    => 1,
    gpgcheck   => 0,
    priority   => 1,
    mirrorlist => absent,
    } -> Package<| provider == 'yum' |>
  class { 'python':
    version    => '34u',
    pip        => false,
    dev        => true,
    virtualenv => true, #!!!    
  } 
  file { '/usr/bin/pip':
    ensure => 'link',
    target => '/usr/bin/pip3.4',
  } 
  file { '/etc/tada/requirements.txt':
    source => "$tadapyreq",
  } 
  python::requirements { '/etc/tada/requirements.txt':
    owner     => 'root',
    subscribe => File['/etc/tada/requirements.txt'],
  }
  Class['python'] -> Package['python34u-pip'] -> File['/usr/bin/pip']
  -> Python::Requirements['/etc/tada/requirements.txt']

  exec { 'dqsvcpop':
    command     => "/usr/bin/dqsvcpop --loglevel ${dqlevel} --queue ${qname} > /var/log/tada/dqpop.log 2>&1 &",
    user        => 'tada',
    environment => ['HOME=/home/tada'],
    creates     => '/var/run/tada/dqsvcpop.pid',
    logoutput   => true,
    #!refreshonly => true,
    require     => [File['/var/run/tada'], Class['redis']],
    subscribe   => [File['/etc/tada/tada.conf'],
                    Python::Requirements[ '/etc/tada/requirements.txt'],
                    ],
  }
  
}
