# == Class: irods
#
# This class will install and configure irods
# see: https://github.com/irods/irods
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'irods':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class irods (
  $setup_input_file = 'setup_irods.input',
  $dbuser = 'irods', # must match IRODS_SERVICE_ACCOUNT_NAME per manual.rst!
  $dbpass = 'irods-sdm',
  ) {
  
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
    } 
    firewall { '101 allow irods':
      chain   => 'INPUT',
      state   => ['NEW'],
      dport   => '20000-20199',
      proto   => 'tcp',
      action  => 'accept',
    }
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
    } ->
  class { 'postgresql::server': } ->
  postgresql::server::db { 'ICAT':
    user     => $dbuser,
    password => $dbpass,
  } 
  
  Package [ 'irods-icat' ] ~>
  Postgresql::Server::Db['ICAT'] ~>
  exec { "/var/lib/irods/packaging/setup_irods.sh < $setup_input_file" :
    creates => '/tmp/irods/setup_irods_configuration.flag',
    } ->
    # Just for "testing"
    exec { '/sbin/service irods status' :
      logoutput => true,
      } ->
      exec { '/bin/su - irods -c ils' :
        logoutput => true,
      } ->
      notify { 'success' : 
        message  => "iRODS is up and running!",
        }
  }
