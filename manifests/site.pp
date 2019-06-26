
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

  # Move tadanat into marsnat but we won't actually use TADA python code
  # Do use dropbox stuff (dataq, watcher)
  include tadanat  
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

