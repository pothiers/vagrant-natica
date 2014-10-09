# after: vagrant ssh
# sudo puppet apply --modulepath=/vagrant/modules /vagrant/manifests/init.pp --noop --graph
# sudo ls /var/lib/puppet/state/graphs/

include augeas

# epel is not needed by the puppet redis module but it's nice to have it
# already configured in the box
include epel
# include concat


class { 'redis':
  version        => '2.8.13',
  redis_password => 'test',
}

user { 'irods':  ensure => 'present', }
user { 'rods':  ensure => 'present', }


$dbuser = 'pg-irods'
$dbpass = 'noao-sdm'
class { 'postgresql::server': } 
postgresql::server::db { 'icat-db':
    user     => $dbuser,
    password => postgresql_password($dbuser,$dbpass),
  } 

    

file { '/etc/irods':
    ensure => directory,
    } ->
file { '/etc/irods/service_account.config':
    content => "IRODS_SERVICE_ACCOUNT_NAME=irods\nIRODS_SERVICE_GROUP_NAME=irods",
    } 
#!file { '/etc/irods/irods.config' :
#!    source => 'puppet:///modules/irods/setupirodsconfig.txt',
#!  }


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

#wget ftp://ftp.renci.org/pub/irods/releases/4.0.3/irods-icat-4.0.3-64bit-centos6.rpm
#sudo rpm -i irods-icat-4.0.3-64bit-centos6.rpm
#wget ftp://ftp.renci.org/pub/irods/releases/4.0.3/irods-database-plugin-postgres-1.3-centos6.rpm
#sudo rpm -i irods-database-plugin-postgres-1.3-centos6.rpm

define irods_package($pname = $title) {
    $rpmname = "$pname-4.0.3-64bit-centos6.rpm"
    wget::fetch { "fetch $pname":
      source      => "ftp://ftp.renci.org/pub/irods/releases/4.0.3/$rpmname",
      destination => '/tmp/$rpmname',
    } ->
    package { "install $pname":
      source   => "/tmp/$rpmname",
      provider => rpm,
    }
  }


$irods_depends = ['postgresql-odbc', 'unixODBC',  'authd', 
                  'fuse-libs',   'openssl098e',  ]
package { $irods_depends : } ->
package { 'irods-icat':
  provider => 'rpm',
  source   =>
'ftp://ftp.renci.org/pub/irods/releases/4.0.3/irods-icat-4.0.3-64bit-centos6.rpm',
  } -> 
package { 'irods-runtime':
  provider => 'rpm',
  source   =>
'ftp://ftp.renci.org/pub/irods/releases/4.0.3/irods-runtime-4.0.3-64bit-centos6.rpm',
  } -> 
package { 'irods-icommands':
  provider => 'rpm',
  source   =>
'ftp://ftp.renci.org/pub/irods/releases/4.0.3/irods-icommands-4.0.3-64bit-centos6.rpm',
  } ->
package { 'irods-database-plugin-postgres':
  provider => 'rpm',
  source   =>
'ftp://ftp.renci.org/pub/irods/releases/4.0.3/irods-database-plugin-postgres-1.3-centos6.rpm',
  } 

#!irods_package { 'irods-icat': } ->
#!irods_package { 'irods-database-plugin-postgres': } ->
#!irods_package { 'irods-runtime': } ->
#!irods_package { 'irods-icommands': } 


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
