# Service resources, and anything else related to the running state of
# the software.
# https://docs.puppetlabs.com/guides/module_guides/bgtm.html

class tada::service (
  $dqlevel  = hiera('dq_loglevel', 'WARNING'),
  $qname    = hiera('queuename'),
  ) {

  exec { 'dqsvcpop':
    command     => "/usr/bin/dqsvcpop --loglevel ${dqlevel} --queue ${qname} > /var/log/tada/dqpop.log 2>&1 &",
    user        => 'tada',
    creates     => '/var/run/tada/dqsvcpop.pid',
    refreshonly => true,
    require     => [File['/var/run/tada'], Class['redis']],
    subscribe   => [File['/etc/tada/tada.conf'],
                    Python::Requirements[ '/vagrant/requirements.txt'],
                    ],
  }

  
  
}

