
if versioncmp($::puppetversion,'3.6.1') >= 0 {
  Package { allow_virtual => true, }
}

node default {
  class {'tada': }
}

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
}

node archive {
  notice("Loading site.pp::archive")
  include mars::install
  include mars::service
  #include mars
  
  
  file { [ '/var/log/mars', '/etc/natica']:
    ensure => 'directory',
    mode   => '0777',
  } ->
  exec { 'patch1':
    command => 'ln -s /etc/mars/django_local_settings.py /etc/natica/django_local_settings.py',
    creates => '/etc/natica/django_local_settings.py',
    path    => ['/usr/bin', '/usr/sbin',],    
    }
}

node db {
  notice("Loading site.pp::db")
  include naticadb
}


#! node goodmars {
#!  ensure_resource('package', ['git', ], {'ensure' => 'present'})
#!  include augeas
#! 
#!  file { [ '/var/run/mars', '/var/log/mars', '/etc/mars', '/var/mars',
#!           '/home/vagrant/sandbox']:
#!    ensure => 'directory',
#!    #group  => 'root',
#!    mode   => '0777',
#!  } ->
#!  vcsrepo { '/home/vagrant/sandbox/mars' :
#!    ensure   => latest,
#!    provider => git,
#!    source   => 'https://github.com/pothiers/mars.git',
#!    #!revision => 'master',
#!    #!revision => '1.4rc3',
#!    revision => 'pat',
#!    owner    => 'vagrant',
#!  }
#! 
#! 
#!  file { '/etc/mars/django_local_settings.py':
#!    replace => false,
#!    source  => hiera('localdjango'),
#!  } 
#! 
#!  file { [ '/var/www', '/var/www/mars', '/var/www/static/',
#!           '/var/www/mars/static']:
#!    ensure => 'directory',
#!  }
#! 
#!  yumrepo { 'ius':
#!    descr      => 'ius - stable',
#!    baseurl    => 'http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/',
#!    enabled    => 1,
#!    gpgcheck   => 0,
#!    priority   => 1,
#!    mirrorlist => absent,
#!  }
#!  -> Package<| provider == 'yum' |>
#! 
#!  package{ ['postgresql', 'postgresql-devel', 'expect'] : } ->
#!  package { ['python34u-pip']: } ->
#!  file { '/opt/mars':
#!    ensure => 'directory',
#!  } ->
#!  file { '/opt/mars/virtualenvs':
#!    ensure => 'directory',
#!  } ->
#!  class { 'python':
#!    version    => '34u',
#!    pip        => false,
#!    #!version    => '35',
#!    #!pip        => true,
#!    dev        => true,
#!  } ->
#!  file { '/usr/bin/pip':
#!    ensure => 'link',
#!    target => '/usr/bin/pip3.4',
#!  } ->
#!  file { '/usr/local/bin/python3':
#!    ensure => 'link',
#!    target => '/usr/bin/python3',
#!    } ->
#!  python::pyvenv { '/var/www/project1' :
#!    ensure       => present,
#!    systempkgs   => true,
#!    venv_dir     => '/opt/mars/virtualenvs',
#!    owner        => 'vagrant',
#!    group        => 'vagrant',
#!    } ->
#!  python::requirements { '/opt/mars/requirements.txt': } 
#! 
#!  file { '/etc/yum.repos.d/nginx.repo':
#!    replace => false,
#!    source => 'puppet:///modules/mars/nginx.repo',
#!  } ->
#!  package { ['nginx'] : }
#! 
#! 
#! 
#! yumrepo { 'mars':
#!   descr    => 'mars',
#!   baseurl  => "http://mirrors.sdm.noao.edu/mars",
#!   enabled  => 1,
#!   gpgcheck => 0,
#!   priority => 1,
#!   mirrorlist => absent,
#! }
#! -> Package<| provider == 'yum' |>
#! 
#!  
#!  # END node: mars
#! 


# To test mars in "deploy" mode (for production)
# Use django with Apache and mod_wsgi
#   https://docs.djangoproject.com/en/1.9/howto/deployment/wsgi/modwsgi/
#! node marsdeploy {
#!   ensure_resource('package', ['git', ], {'ensure' => 'present'})
#!   include augeas
#!   
#!   class { 'apache': } ->
#!   apache::vhost { 'www.mars.vagrant.com':
#!     port   => '80',
#!     docroot => '/var/www/mars',
#!   } ->
#!   class { 'apache::mod::wsgi':
#!     wsgi_python_home => '/opt/mars/venv',
#!   } 
#!   
#! 
#!   file { [ '/var/run/mars', '/var/log/mars', '/etc/mars', '/var/mars',
#!            '/home/vagrant/sandbox']:
#!     ensure => 'directory',
#!     mode   => '0777',
#!   } ->
#!   vcsrepo { '/home/vagrant/sandbox/mars' :
#!     ensure   => latest,
#!     provider => git,
#!     source   => 'https://github.com/pothiers/mars.git',
#!     #revision => 'master',
#!     #revision => '1.4rc7',
#!     revision => 'pat',
#!     owner    => 'vagrant',
#!   }
#! 
#!   file { '/etc/mars/django_local_settings.py':
#!     replace => false,
#!     source  => hiera('localdjango'),
#!   } 
#! 
#!   file { [ '/var/www', '/var/www/mars', '/var/www/static/',
#!            '/var/www/mars/static']:
#!     ensure => 'directory',
#!   }
#! 
#!   yumrepo { 'ius':
#!     descr      => 'ius - stable',
#!     baseurl    => 'http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/',
#!     enabled    => 1,
#!     gpgcheck   => 0,
#!     priority   => 1,
#!     mirrorlist => absent,
#!   }
#!   -> Package<| provider == 'yum' |>
#! 
#!   package{ ['postgresql', 'postgresql-devel', 'expect'] : } ->
#!   package { ['python34u-pip']: } ->
#!   file { '/opt/mars':
#!     ensure => 'directory',
#!   } ->
#!   class { 'python':
#!     version    => '34u',
#!     pip        => false,
#!     dev        => true,
#!   } ->
#!   file { '/usr/bin/pip':
#!     ensure => 'link',
#!     target => '/usr/bin/pip3.4',
#!   } ->
#!   file { '/usr/local/bin/python3':
#!     ensure => 'link',
#!     target => '/usr/bin/python3',
#!   } ->
#!   python::pyvenv { '/var/www/project2' :
#!     ensure       => present,
#!     systempkgs   => true,
#!     venv_dir     => '/opt/mars/virtualenvs',
#!     owner        => 'vagrant',
#!     group        => 'vagrant',
#!   } ->
#!   python::requirements { '/opt/mars/requirements.txt': } 
#! 
#!   file { '/etc/yum.repos.d/nginx.repo':
#!     replace => false,
#!     source => 'puppet:///modules/mars/nginx.repo',
#!   } ->
#!   package { ['nginx'] : }
#! 
#!   
#! } # END node: marsdeploy
