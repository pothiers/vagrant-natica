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
  #!config.ssh.forward_x11 = true
  #! config.vm.provision "shell",
  #!   inline: "yum upgrade -y puppet" #! Remove for production!!!

  config.vm.synced_folder "..", "/sandbox"
  config.vm.synced_folder "../tada-tools/dev-scripts", "/dbin"
  config.vm.synced_folder "../../logs", "/logs"
  config.vm.synced_folder "../../data", "/data"
  # WARNING: DMO is using puppet version 3.8.6  (not version 4.*)
  # Uses Puppet version 4.3.2
  #!config.vm.box     = 'puppetlabs/centos-6.6-64-puppet'
  #!config.vm.box_url = 'https://atlas.hashicorp.com/puppetlabs/boxes/centos-6.6-64-puppet'
  config.vm.box     = 'vStone/centos-6.x-puppet.3.x'
  config.vm.box_url = 'https://atlas.hashicorp.com/vStone/boxes/centos-6.x-puppet.3.x'
config.vm.box = "vStone/centos-6.x-puppet.3.x"

  
  # Attempt to speed up connection to remote hosts
  # (e.g. connection to MARS services)
  config.vm.provider :virtualbox do |vb|
    # No luck with this pair; doesn't break, but still slow
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
    #vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]

    # Try this; won't boot from chimp16
    #vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
  end    
  

  ##############################################################################
  ### LSA System

  config.vm.define "mountain" do |mountain| #LSA
    mountain.vm.network :private_network, ip: "172.16.1.11"
    mountain.vm.hostname = "mountain.vagrant.noao.edu" 
    mountain.hostmanager.aliases =  %w(mountain)
    mountain.vm.provision :puppet do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file = "site.pp"
      puppet.module_path = ["modules", "../puppet-modules"]
      puppet.environment_path = "environments"
      #!puppet.environment = "pat"
      puppet.environment = "dev"
      puppet.options = [
       '--verbose',
       '--report',
       '--show_diff',
       '--pluginsync',
       '--hiera_config /vagrant/hiera.yaml',
       #!'--debug', #+++ #! Remove for production!!!
       #'--graph',
       #'--graphdir /vagrant/graphs/mountain',
      ]
    end
  end

  config.vm.define "valley" do |valley| #LSA
    valley.vm.network :private_network, ip: "172.16.1.12"
    valley.vm.hostname = "valley.vagrant.noao.edu"
    valley.hostmanager.aliases =  %w(valley)
    valley.vm.provision :puppet do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file = "site.pp" 
      puppet.module_path = ["modules", "../puppet-modules"]
      puppet.environment_path = "environments"
      #!puppet.environment = "pat"
      puppet.environment = "dev"
      puppet.options = [
       '--verbose',
       '--report',
       '--show_diff',
       '--pluginsync',
       '--hiera_config /vagrant/hiera.yaml',
       #!'--debug', #+++
       #!'--graph',
       #!'--graphdir /vagrant/graphs/valley',
      ]
    end

    valley.vm.provision "shell" do |s|
      ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
      s.inline = <<-SHELL
        echo #{ssh_pub_key} >> /home/tester/.ssh/authorized_keys
        echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
      SHELL
    end
    
  end

  config.vm.define "mars" do |mars| #LSA
    mars.vm.network :private_network, ip: "172.16.1.13"
    mars.vm.network :forwarded_port, guest: 8000, host: 8000
    mars.vm.network :forwarded_port, guest: 8001, host: 8001
    mars.vm.hostname = "mars.vagrant.noao.edu" 
    mars.hostmanager.aliases =  %w(mars)
    
    mars.vm.provision :puppet do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file = "site.pp"
      puppet.module_path = ["modules", "../puppet-modules"]
      puppet.environment_path = "environments"
      #!puppet.environment = "pat"
      puppet.environment = "dev"
      puppet.options = [
        #!'--debug', #+++
        '--verbose',
        '--report',
        '--show_diff',
        '--pluginsync',
        '--hiera_config /vagrant/hiera.yaml',
      ]
    end
  end

  ##############################################################################
  ### NATICA System

  config.vm.define "mtnnat" do |mtnnat| #natica
    mtnnat.vm.network :private_network, ip: "172.16.1.21"
    mtnnat.vm.hostname = "mtnnat.vagrant.noao.edu" 
    mtnnat.hostmanager.aliases =  %w(mtnnat)
    # COMMENT OUT TO SPEED VM CREATION (if small disk is good enough)
    # disk to use for cache
    #! mtnnat.vm.provider "virtualbox" do | v |
    #!   v.customize ['createhd', '--filename', mtnnat_disk,
    #!                '--size', 200 * 1024]
    #!   # list all controllers: "VBoxManage  list vms --long"
    #!   v.customize ['storageattach', :id, '--storagectl', 'IDE Controller',
    #!                '--port', 1, '--device', 0, '--type', 'hdd',
    #!                '--medium', mtnnat_disk]
    #! end
    #! mtnnat.vm.provision "shell", path: "disk2.sh"
    
    mtnnat.vm.provision :puppet do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file = "site.pp"
      puppet.module_path = ["modules", "../puppet-modules"]
      puppet.environment_path = "environments"
      #!puppet.environment = "pat"
      puppet.environment = "dev"
      puppet.options = [
       '--verbose',
       '--report',
       '--show_diff',
       '--pluginsync',
       '--hiera_config /vagrant/hiera.yaml',
       #!'--debug', #+++ #! Remove for production!!!
       #'--graph',
       #'--graphdir /vagrant/graphs/mtnnat',
      ]
    end
  end

  config.vm.define "valnat" do |valnat| #natica
    valnat.vm.network :private_network, ip: "172.16.1.22"
    valnat.vm.hostname = "valnat.vagrant.noao.edu"
    valnat.hostmanager.aliases =  %w(valnat)
    valnat.vm.provision :puppet do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file = "site.pp" 
      puppet.module_path = ["modules", "../puppet-modules"]
      puppet.environment_path = "environments"
      #!puppet.environment = "pat"
      puppet.environment = "dev"
      puppet.options = [
       '--verbose',
       '--report',
       '--show_diff',
       '--pluginsync',
       '--hiera_config /vagrant/hiera.yaml',
       #!'--debug', #+++
       #!'--graph',
       #!'--graphdir /vagrant/graphs/valnat',
      ]
    end

    valnat.vm.provision "shell" do |s|
      ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
      s.inline = <<-SHELL
        echo #{ssh_pub_key} >> /home/tester/.ssh/authorized_keys
        echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
      SHELL
    end
    
  end

  
  config.vm.define "marsnat" do |marsnat| # new mars containing natica
    marsnat.vm.network :private_network, ip: "172.16.1.23"
    marsnat.vm.network :forwarded_port, guest: 8000, host: 8020
    marsnat.vm.network :forwarded_port, guest: 8001, host: 8021
    marsnat.vm.hostname = "marsnat.vagrant.noao.edu" 
    marsnat.hostmanager.aliases =  %w(marsnat)
    
    marsnat.vm.provision :puppet do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file = "site.pp"
      puppet.module_path = ["modules", "../puppet-modules"]
      puppet.environment_path = "environments"
      #!puppet.environment = "pat"
      puppet.environment = "dev"
      puppet.options = [
        #!'--debug', #+++
        '--verbose',
        '--report',
        '--show_diff',
        '--pluginsync',
        '--hiera_config /vagrant/hiera.yaml',
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
      puppet.module_path = ["modules", "../puppet-modules"]
      puppet.environment_path = "environments"
      #!puppet.environment = "pat"
      puppet.environment = "dev"
      puppet.options = [
        #!'--debug', #+++
        '--verbose',
        '--report',
        '--show_diff',
        '--pluginsync',
        '--hiera_config /vagrant/hiera.yaml',
        #!'--graph',
        #!'--graphdir /vagrant/graphs/dbnat',
      ]
    end
  end
  
  ###
  ### END NATICA system
  ##############################################################################

  ##############################################################################
  ### Prototype
  
  config.vm.define "archive" do |archive| # use with NATICA prototype only
    archive.vm.network :private_network, ip: "172.16.1.15"
    # inside vagrant is GUEST, from the host running vagrant its HOST
    archive.vm.network :forwarded_port, guest: 8000, host: 8080 
    archive.vm.network :forwarded_port, guest: 8001, host: 8081
    archive.vm.hostname = "archive.vagrant.noao.edu" 
    archive.hostmanager.aliases =  %w(archive)
    
    archive.vm.provision :puppet do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file = "site.pp"
      puppet.module_path = ["modules", "../puppet-modules"]
      puppet.environment_path = "environments"
      #!puppet.environment = "pat"
      puppet.environment = "dev"
      puppet.options = ['--verbose', '--report', '--show_diff', '--pluginsync',
        '--hiera_config /vagrant/hiera.yaml', ]
    end
  end

  
end

