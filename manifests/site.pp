
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
  include marsnat::install
  include marsnat::service
} 
node mtnnat {
  include tadanat
} 
node valnat {
  include tadanat
}


###
### END NATICA system
##############################################################################

