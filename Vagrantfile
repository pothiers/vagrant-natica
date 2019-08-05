# -*- mode: ruby -*-

valley_disk = './valley_disk.vdi'
mountain_disk = './mountain_disk.vdi'
PUPPETENV = "dev"


##How to set vagrant virtualbox video memory
##
## You'll need to use the following config:
## 
## config.vm.provider "virtualbox" do |v|
##    v.customize ["modifyvm", :id, "--vram", "<vramsize in MB>"]
## end
## 
## How I found this? I looked at VirtualBox docs but haven't found
## anything about 'Video' or 'Memory' that seem related to video
## memory. So I ran VBoxManage showvminfo <vm name> command and looked
## for the line with the amount of video memory I have set in Virtualbox
## GUI (12MB).


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
  #!config.vm.provision "shell",
  #!  inline: "yum upgrade -y puppet" #! Remove for production!!!

  config.vm.synced_folder "..", "/sandbox"
  config.vm.synced_folder "../../data", "/data"
  #!config.vm.synced_folder "../tada-tools/dev-scripts", "/dbin"
  #!config.vm.synced_folder "../../logs", "/logs"


  # DMO demo machines: Puppet-3.7.5, OS=SL-7.4
  # DMO dev.dm machines: Puppet-5.5.1, OS=SL-7.5
  #!config.vm.box = "vStone/centos-7.x-puppet.3.x" # atlas is GONE
  #!config.vm.box_version = "1.0.0"
  #!config.vm.box = "zlee/centos7-puppet5"

  #!config.vm.box = "gutocarvalho/scientific7x64puppet5"
  #!config.vm.box = "adrianovieira/centos7x64_minimal-puppet5"
  #!config.vm.box_version = "5.3.2"
  config.vm.box = "aeciopires/centos-7"
  config.vm.box_version = "1.0.0"
  
  # Attempt to speed up connection to remote hosts
  # (e.g. connection to MARS services)
  config.vm.provider :virtualbox do |vb|
    # No luck with this pair; doesn't break, but still slow
    #!vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on" ]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "off", "--vram", "12"]
    #vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    #!vb.gui = true
  end    

  ##############################################################################
  ### NATICA System

  config.vm.define "marsnat" do |marsnat| # new mars containing natica
    marsnat.vm.network :private_network, ip: "172.16.1.23"
    marsnat.vm.network :forwarded_port, guest: 8000, host: 8020
    marsnat.vm.network :forwarded_port, guest: 8001, host: 8021
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

