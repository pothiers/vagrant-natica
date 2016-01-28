# -*- mode: ruby -*-
# vi: set ft=ruby :

valley_disk = './valley_disk.vdi'
mountain_disk = './mountain_disk.vdi'


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
  config.ssh.forward_x11 = true

  #! config.vm.provision "shell",
  #!   inline: "yum upgrade -y puppet" #! Remove for production!!!

  config.vm.synced_folder "..", "/sandbox"
  config.vm.synced_folder "../../dev-scripts", "/dbin"
  config.vm.synced_folder "../../logs", "/logs"
  config.vm.synced_folder "../../data", "/data"
  config.vm.box     = 'puppetlabs/centos-6.6-64-puppet'
  config.vm.box_url = 'https://atlas.hashicorp.com/puppetlabs/boxes/centos-6.6-64-puppet'
  
  
  config.vm.define "mountain" do |mountain|
    mountain.vm.network :private_network, ip: "172.16.1.11"
    mountain.vm.hostname = "mountain.test.noao.edu" 
    mountain.hostmanager.aliases =  %w(mountain)

    # COMMENT OUT TO SPEED VM CREATION (if small disk is good enough)
    # disk to use for mountain-mirror
    mountain.vm.provider "virtualbox" do | v |
      v.customize ['createhd', '--filename', mountain_disk,
                   '--size', 200 * 1024]
      # list all controllers: "VBoxManage  list vms --long"
      v.customize ['storageattach', :id, '--storagectl', 'IDE Controller',
                   '--port', 1, '--device', 0, '--type', 'hdd',
                   '--medium', mountain_disk]
    end
    mountain.vm.provision "shell", path: "disk2.sh"

    
    mountain.vm.provision :puppet do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file = "site.pp"
      puppet.module_path = ["modules", "../puppet-modules"]

      puppet.options = [
       '--verbose',
       '--report',
       '--show_diff',
       '--graph',
       '--graphdir /vagrant/graphs/mountain',
       '--pluginsync',
       '--hiera_config /vagrant/hiera.yaml',
       #!'--debug', #+++ #! Remove for production!!!
      ]
    end
  end

  config.vm.define "valley" do |valley|
    valley.vm.network :private_network, ip: "172.16.1.12"
    valley.vm.hostname = "valley.test.noao.edu"
    valley.hostmanager.aliases =  %w(valley)

    # COMMENT OUT TO SPEED VM CREATION
    # disk to use for mountain-mirror
    valley.vm.provider "virtualbox" do | v |
      v.customize ['createhd', '--filename', valley_disk,
                   '--size', 200 * 1024,  # megabytes
                  ]
      # list all controllers: "VBoxManage  list vms --long"
      v.customize ['storageattach', :id, '--storagectl', 'IDE Controller',
                   '--port', 1, '--device', 0, '--type', 'hdd',
                   '--medium', valley_disk]
    end
    valley.vm.provision "shell", path: "disk2.sh"
      
    valley.vm.provision :puppet do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file = "site.pp" 
      puppet.module_path = ["modules", "../puppet-modules"]


      puppet.options = [
       '--verbose',
       '--report',
       '--show_diff',
       '--graph',
       '--graphdir /vagrant/graphs/valley',
       '--pluginsync',
       '--hiera_config /vagrant/hiera.yaml',
       #!'--debug', #+++
      ]
    end
  end

end
