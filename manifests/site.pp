
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
}

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
  
}

