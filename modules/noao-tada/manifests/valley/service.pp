class tada::valley::service (
  $dqlevel  = hiera('dq_loglevel', 'WARNING'),
  $qname    = hiera('queuename'),
  $dqlog    = hiera('dqlog'),
  ) {

  exec { 'dqsvcpop':
    command     => "/usr/bin/dqsvcpop --loglevel ${dqlevel} --queue ${qname} > ${dqlog} 2>&1 &",
    cwd         => '/home/tada',
    environment => 'HOME=/home/tada',
    user        => 'tada',
    umask       => '000',
    creates     => '/var/run/tada/dqsvcpop.pid',
    refreshonly => true,
    require     => [File['/var/run/tada'],
                    Class['redis'],
                    Exec['iinit'],
                    ],
    subscribe   => [File['/etc/tada/tada.conf'],
                    Python::Requirements[ '/vagrant/requirements.txt'],
                    Exec['iinit'],
                    ],
  }

  
  
}

