# after: vagrant ssh
# sudo puppet apply --modulepath=/vagrant/modules /vagrant/manifests/init.pp --noop --graph
# sudo cp -r /var/lib/puppet/state/graphs/ /vagrant/

include augeas

# epel is not needed by the puppet redis module but it's nice to have it
# already configured in the box
include epel

package { 'emacs' : }


class { 'redis':
  version        => '2.8.13',
  redis_password => 'test',
}

class { 'irods':
  setup_input_file =>  '/vagrant/modules/irods/files/setup_irods.input',
}

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
} ->
package { 'python34u-pip': } ->
file { '/usr/bin/pip':
  ensure => 'link',
  target => '/usr/bin/pip3.4',
} ->
package { 'graphviz-devel': } ->
python::requirements { '/vagrant/requirements.txt': } ->

# Get from github now. But its in PyPI for when things stabalize!!!
python::pip {'daflsim':
  pkgname => 'daflsim',
  url     => 'https://github.com/pothiers/daflsim/archive/master.zip',
}

# Orig is "pre-alpha".  Better to avoid it now. Orig is also python 2.7,
# this branch upgraded to universal -- maybe.
#
#!python::pip {'irodsclient':
#!  url => 'https://github.com/pothiers/python-irodsclient/archive/master.zip',
#!}

