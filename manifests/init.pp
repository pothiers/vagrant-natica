# after: vagrant ssh
# sudo puppet apply --modulepath=/vagrant/modules /vagrant/manifests/init.pp --noop --graph
# sudo ls /var/lib/puppet/state/graphs/

include augeas

# epel is not needed by the puppet redis module but it's nice to have it
# already configured in the box
include epel

package { 'emacs' : } 

class { 'redis':
  version        => '2.8.13',
  redis_password => 'test',
}

user { 'irods':  
  ensure => 'present', 
    home => '/var/lib/irods/iRODS', # circular dependencies!!!
    managehome => false,
  } ->
file { '/var/lib/irods':
    ensure => directory,
    owner   => 'irods',
    mode    => 'u+wX',
    recurse => true,
    } 

user { 'rods':  
  ensure => 'present', 
  password => 'rods',
  }


$dbuser = 'irods' # must match IRODS_SERVICE_ACCOUNT_NAME per manual.rst!
$dbpass = 'irods-sdm'
class { 'postgresql::server': } 
postgresql::server::db { 'ICAT':
    user     => $dbuser,
    password => $dbpass,
  } 
    

file { '/etc/irods':
    ensure => directory,
    owner  => 'irods',
    recurse => true,
    } ->
file { '/etc/irods/service_account.config':
   content => "IRODS_SERVICE_ACCOUNT_NAME=irods\nIRODS_SERVICE_GROUP_NAME=irods\n",
  } ->
file { '/etc/irods/irods.config' :
    source => '/vagrant/modules/irods/setupirodsconfig.txt',
    owner  => 'irods',
    mode   => 'u+w',
  } ->
#exec { '/var/lib/irods/packaging/setup_irods.sh' :  
notify { 'run setup_irods_puppet.sh' : } ->
exec { '/vagrant/modules/irods/setup_irods_puppet.sh' :  # !!!
    creates => '/tmp/irods/setup_irods_configuration.flag',
    logoutput => true,
    }

################### 
### Firewall setup
# Clear any existing rules and make sure that only rules defined in
# Puppet exist on the machine.
resources { "firewall":
  purge => true
}

Firewall {
  before  => Class['irods_fw::post'],
  require => Class['irods_fw::pre'],
}

class { ['irods_fw::pre', 'irods_fw::post']: }

class { 'firewall': }

class irods_fw::pre {
  Firewall {
    require => undef,
  }

 # IRODS
 firewall { '100 allow irods':
    chain   => 'INPUT',
    state   => ['NEW'],
    dport   => '1247',
    proto   => 'tcp',
    action  => 'accept',
    }->
 firewall { '101 allow irods':
    chain   => 'INPUT',
    state   => ['NEW'],
    dport   => '20000-20199',
    proto   => 'tcp',
    action  => 'accept',
    }->
 firewall { '102 allow irods':
    chain   => 'INPUT',
    state   => ['NEW'],
    dport   => '20000-20199',
    proto   => 'udp',
    action  => 'accept',
    }
}

class irods_fw::post {
  Firewall {
    require => undef,
  }
  # Default firewall rules
  # (none)
}

$irods_depends = ['postgresql-odbc', 'unixODBC',  'authd', 
                  'fuse-libs',   'openssl098e',  ]
$irodsbase = "ftp://ftp.renci.org/pub/irods/releases/4.0.3"
package { $irods_depends : } ->
package { 'irods-icat':
  provider => 'rpm',
  source   => "$irodsbase/irods-icat-4.0.3-64bit-centos6.rpm",
  } -> 
#!package { 'irods-resource':
#!  provider => 'rpm',
#!  source   => "$irodsbase/irods-resource-4.0.3-64bit-centos6.rpm",
#!  } -> 
package { 'irods-runtime':
  provider => 'rpm',
  source   => "$irodsbase/irods-runtime-4.0.3-64bit-centos6.rpm",
  } -> 
package { 'irods-icommands':
  provider => 'rpm',
  source   => "$irodsbase/irods-icommands-4.0.3-64bit-centos6.rpm",
  } ->
package { 'irods-database-plugin-postgres':
  provider => 'rpm',
  source   => "$irodsbase/irods-database-plugin-postgres-1.3-centos6.rpm",
  } 



##############################################################################
### Still tto go
###
#! sudo sed -ibak s/-E//  /etc/xinetd.d/auth 
#! sudo /sbin/chkconfig --level=3 auth on
#! sudo /etc/init.d/xinetd restart
###
##############################################################################

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
  virtualenv => true,
}

package { 'python34u-pip': } ->
file { '/usr/bin/pip':
  ensure => 'link',
  target => '/usr/bin/pip3.4',
} ->


package { 'graphviz-devel': } ->
python::requirements { '/vagrant/requirements.txt': }

python::pip {'daflsim': 
    pkgname => 'daflsim',
    url => 'https://github.com/pothiers/daflsim/archive/master.zip',
    }
