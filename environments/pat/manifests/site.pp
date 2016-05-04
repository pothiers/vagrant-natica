
if versioncmp($::puppetversion,'3.6.1') >= 0 {
  Package { allow_virtual => true, }
}

node default {
  class {'tada': }
}

node mountain {
  include tada
  include tada::mountain
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
