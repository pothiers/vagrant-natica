# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.provision "shell",
    inline: "yum upgrade -y puppet"

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.auto_detect = true
    config.cache.scope       = :box
  end

  config.vm.box     = 'centos65'
  config.vm.box_url = 'http://puppet-vagrant-boxes.puppetlabs.com/centos-65-x64-virtualbox-puppet.box'

  config.vm.define "mountain" do |mountain|
    mountain.vm.network :private_network, type: "dhcp"
    mountain.vm.hostname = "mountain"
  end

  config.vm.define "valley" do |valley|
    #! valley.vm.network :private_network, ip: "192.168.11.4"
    valley.vm.network :private_network, type: "dhcp"
    valley.vm.hostname = "valley"

    # Enable provisioning with Puppet stand alone.  Puppet manifests
    # are contained in a directory path relative to this Vagrantfile.
    # You will need to create the manifests directory and a manifest in
    # the file default.pp in the manifests_path directory.
    #
    valley.vm.provision :puppet do |puppet|
      puppet.manifests_path = "manifests"
      puppet.module_path = "modules"
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
