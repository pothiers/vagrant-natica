
if versioncmp($::puppetversion,'3.6.1') >= 0 {
  Package { allow_virtual => true, }
}

#!node default {
#!  class {'tada': }
#!}

##############################################################################
### LSA System

node mountain {
  include tada
  include tada::mountain
  package{ ['mailx'] : }

  @user { 'vagrant':
    groups     => ["vagrant"],
    membership => minimum,
  }

  User <| title == vagrant |> { groups +> "tada" }
  file { [ '/home/vagrant/bin']:
    ensure => 'directory',
    owner   => 'vagrant',
    group   => 'tada',
  }
  file { '/home/vagrant/bin/install.sh':
    ensure  => 'present',
    content  => "#/bin/sh\n/sandbox/tada-tools/dev-scripts/install.sh\n",
    owner   => 'vagrant',
    group   => 'tada',
    mode    => '0744',
  }
}

# /sandbox/tada-tools/dev-scripts/

node valley {
  include tada
  include tada::valley
  package{ ['mailx', 'rpm-build', 'ruby', 'rubygems', 'ruby-devel'] : }
  # sudo gem install fpm ## WILL FAIL  but allows next to work
  # sudo gem install fpm --version 1.4.0
  # fpm --python-bin python3 -s python -t rpm setup.py

  
  $rsyncpwd       = hiera('rsyncpwd')

  @user { 'vagrant':
    groups     => ["vagrant"],
    membership => minimum,
  }
  User <| title == vagrant |> { groups +> "tada" }

  file { '/home/vagrant/.tada':
    ensure  => 'directory',
    owner   => 'vagrant',
    group   => 'tada',
    mode    => '0744',
  }
  file { '/home/vagrant/.tada/rsync.pwd':
    ensure  => 'present',
    owner   => 'vagrant',
    group   => 'tada',
    mode    => '0400',
    source  => "${rsyncpwd}",
 } 
  file { [ '/home/vagrant/bin']:
    ensure => 'directory',
    owner   => 'vagrant',
    group   => 'tada',
  }
  file { '/home/vagrant/bin/install.sh':
    ensure  => 'present',
    content  => "#/bin/sh\n/sandbox/tada-tools/dev-scripts/install.sh\n",
    owner   => 'vagrant',
    group   => 'tada',
    mode    => '0744',
  }
  file { '/home/vagrant/bin/smoke.all.sh':
    ensure  => 'present',
    content  => "#/bin/sh\n/sandbox/tada/tests/smoke/smoke.all.sh\n",
    owner   => 'vagrant',
    group   => 'tada',
    mode    => '0744',
  }

} # END: node valley

node mars {
  notice("Loading site.pp::mars")
  include mars::install
  include mars::service
  #include mars

  # sudo chown vagrant /etc/mars/rsync.pwd
}

###
### END LSA system
##############################################################################


##############################################################################
### NATICA System

node marsnat {
  notice("Loading site.pp::marsnat 3")
  #!include 'marsnat'   #!!! NOT WORKING
  include marsnat::install
  include marsnat::service
}

node dbnat {
  notice("Loading site.pp::dbnat")
  include naticadb
}

node mtnnat {
  include tadanat
}
node valnat {
  include tadanat
}


###
### END NATICA system
##############################################################################


node archive {
  notice("Loading site.pp::archive")
  file { [ '/etc/natica', '/opt/natica']: 
    ensure => 'directory',
    mode   => '0777',
  } ->
  exec { 'patch1':
    command => 'ln -s /etc/mars/django_local_setgtings.py /etc/natica/django_local_settings.py',
    creates => '/etc/natica/django_local_settings.py',
    path    => ['/usr/bin', '/usr/sbin',],    
  }
  python::pyvenv  { '/opt/natica/venv':
    version  => '3.5',
    owner    => 'devops',
    group    => 'devops',
    require  => [ User['devops'], ],
  } ->
  python::requirements  { '/sandbox/natica/requirements.txt':
    virtualenv => '/opt/natica/venv',
    owner    => 'devops',
    group    => 'devops',
    require  => [ User['devops'], ],
  }
  include mars::install
  include mars::service
}

#!node natica {
#!  notice("Loading site.pp::natica")
#!  include natica::install
#!  include natica::service
#!}
