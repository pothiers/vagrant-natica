# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  #! vagrant plugin install vagrant-cachier
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.auto_detect = true
    config.cache.scope       = :box
  end

  #! vagrant plugin install vagrant-hostmanager
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = false
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true


  config.vm.provision "shell",
    inline: "yum upgrade -y puppet"

  config.vm.box     = 'centos65'
  config.vm.box_url = 'http://puppet-vagrant-boxes.puppetlabs.com/centos-65-x64-virtualbox-puppet.box'

  config.vm.define "mountain" do |mountain|
    mountain.vm.network :private_network, ip: "172.16.1.11"
    mountain.vm.hostname = "mountain"

    mountain.vm.provision :puppet do |puppet|
      puppet.manifests_path = "mountain/manifests"
      puppet.module_path = "mountain/modules"
      puppet.manifest_file = "init.pp"
      puppet.options = [
       '--verbose',
       '--report',
       '--show_diff',
       '--pluginsync',
      ]
    end

  end

  config.vm.define "valley" do |valley|
    valley.vm.network :private_network, ip: "172.16.1.12"
    valley.vm.hostname = "valley"

    valley.vm.provision :puppet do |puppet|
      puppet.manifests_path = "valley/manifests"
      puppet.module_path = "valley/modules"
      puppet.manifest_file = "init.pp"
      puppet.options = [
       '--verbose',
       '--report',
       '--show_diff',
       '--pluginsync',
  # '--debug',
  # '--parser future',
      ]
    end

  end

end
