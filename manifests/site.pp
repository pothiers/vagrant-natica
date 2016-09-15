
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
  package{ ['mailx'] : }
  
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

}

#node FUTUREmars {
#  notice("Loading site.pp::mars")
#  include mars
#}

node mars {
  ensure_resource('package', ['git', ], {'ensure' => 'present'})
  include augeas

  file { [ '/var/run/mars', '/var/log/mars', '/etc/mars', '/var/mars',
           '/home/vagrant/sandbox']:
    ensure => 'directory',
    #group  => 'root',
    mode   => '0777',
  } ->
  vcsrepo { '/home/vagrant/sandbox/mars' :
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/pothiers/mars.git',
    #!revision => 'master',
    #!revision => '1.4rc3',
    revision => 'pat',
    owner    => 'vagrant',
  }


  file { '/etc/mars/django_local_settings.py':
    replace => false,
    source  => hiera('localdjango'),
  } 

  file { [ '/var/www', '/var/www/mars', '/var/www/static/',
           '/var/www/mars/static']:
    ensure => 'directory',
  }

  yumrepo { 'ius':
    descr      => 'ius - stable',
    baseurl    => 'http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/',
    enabled    => 1,
    gpgcheck   => 0,
    priority   => 1,
    mirrorlist => absent,
  }
  -> Package<| provider == 'yum' |>

  package{ ['postgresql', 'postgresql-devel', 'expect'] : } ->
  package { ['python34u-pip']: } ->
  class { 'python':
    version    => '34u',
    pip        => false,
    #!version    => '35',
    #!pip        => true,
    dev        => true,
  } ->
  file { '/usr/bin/pip':
    ensure => 'link',
    target => '/usr/bin/pip3.4',
  } ->
  file { '/usr/local/bin/python3':
    ensure => 'link',
    target => '/usr/bin/python3',
    } ->
  python::pyvenv { '/var/www/project1' :
    ensure       => present,
    systempkgs   => true,
    venv_dir     => '/opt/mars/virtualenvs',
    owner        => 'vagrant',
    group        => 'vagrant',
    } ->
  python::requirements { '/opt/mars/requirements.txt': } 

  file { '/etc/yum.repos.d/nginx.repo':
    replace => false,
    source => 'puppet:///modules/mars/nginx.repo',
  } ->
  package { ['nginx'] : }



#! yumrepo { 'mars':
#!   descr    => 'mars',
#!   baseurl  => "http://mirrors.sdm.noao.edu/mars",
#!   enabled  => 1,
#!   gpgcheck => 0,
#!   priority => 1,
#!   mirrorlist => absent,
#! }
#! -> Package<| provider == 'yum' |>

  
}

