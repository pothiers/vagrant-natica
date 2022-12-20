# -*- mode: ruby -*-
# DEV for NATICA using libvirt

PUPPETENV = "dev"

### Do these before using:
# vagrant plugin install vagrant-cachier
# vagrant plugin install vagrant-hostmanager
#
## https://ostechnix.com/how-to-use-vagrant-with-libvirt-kvm-provider/
#
# vagrant plugin install vagrant-libvirt
# vagrant plugin install vagrant-mutate

Vagrant.configure("2") do |config|
  #! Do this before using: vagrant plugin install vagrant-cachier
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.auto_detect = true
    config.cache.scope       = :box
  end

  #! Do this before using: vagrant plugin install vagrant-hostmanager
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = false
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  config.ssh.forward_agent = true
  config.vm.synced_folder "..", "/sandbox"
  config.vm.synced_folder "../../data", "/data"


  #!config.vm.box = "gutocarvalho/scientific7x64puppet5"
  #!config.vm.box = "adrianovieira/centos7x64_minimal-puppet5"
  #!config.vm.box_version = "5.3.2"
  config.vm.box = "aeciopires/centos-7"
  config.vm.box_version = "1.0.0"

  #! # Attempt to speed up connection to remote hosts
  #! # (e.g. connection to MARS services)
  #! config.vm.provider :virtualbox do |vb|
  #!   vb.customize ["modifyvm", :id, "--natdnsproxy1", "off", "--vram", "12"]
  #! end

  ##############################################################################
  ### NATICA System

  config.vm.define "marsnat" do |marsnat| # new mars containing natica
    marsnat.vm.network :private_network, ip: "172.16.1.23"
    marsnat.vm.network :forwarded_port, guest: 8000, host: 8020
    marsnat.vm.network :forwarded_port, guest: 80, host: 8021
    marsnat.vm.network :forwarded_port, guest: 443, host: 443
    marsnat.vm.hostname = "marsnat.vagrant.noao.edu"
    marsnat.hostmanager.aliases =  %w(marsnat)

    marsnat.vm.provision :puppet do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file = "site.pp"
      puppet.module_path = ["../puppet-modules", "modules"]
      puppet.environment = PUPPETENV
      puppet.environment_path = "environments"
      puppet.hiera_config_path = "hiera.yaml"
      puppet.options = [
        #! '--debug',
        '--verbose',
        '--report',
        '--show_diff',
      ]
    end
  end

  # For use with natica
  config.vm.define "dbnat" do |dbnat| #natica
    dbnat.vm.network :private_network, ip: "172.16.1.24"
    dbnat.vm.network :forwarded_port, guest: 8010, host: 8010
    dbnat.vm.hostname = "dbnat.vagrant.noao.edu"
    dbnat.hostmanager.aliases =  %w(dbnat)

    dbnat.vm.provision :puppet do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file = "site.pp"
      puppet.module_path = ["../puppet-modules", "modules"]
      puppet.environment = PUPPETENV
      puppet.environment_path = "environments"
      puppet.hiera_config_path = "hiera.yaml"
      puppet.options = [
        '--verbose',
        '--report',
        '--show_diff',
        #!'--graph',
        #!'--graphdir /vagrant/graphs/dbnat',
      ]
    end
  end

  ###
  ### END NATICA system
  ##############################################################################

end
