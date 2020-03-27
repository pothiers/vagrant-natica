
if versioncmp($::puppetversion,'3.6.1') >= 0 {
  Package { allow_virtual => true, }
}


##############################################################################
### NATICA System

node dbnat {
  notice("Loading site.pp::dbnat")
  include naticadb
} 

node marsnat {
  notice("Loading site.pp::marsnat")
  
  # sudo usermod -aG devops,tester,tada vagrant
  group { ['devops', 'tester', 'cache'] :
    ensure => present,
  }         
  user { 'vagrant':
    ensure => present,
    groups => ['devops', 'tester', 'tada', 'cache'],
  }

  include marsnat::config
  include marsnat::install
  include marsnat::service

} 
#!node mtnnat {
#!  include tadanat
#!} 
#!node valnat {
#!  include tadanat
#!}


###
### END NATICA system
##############################################################################

