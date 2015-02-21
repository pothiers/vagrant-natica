echo "START: Provision mountain and ssh to it."

vagrant provision mountain --provision-with puppet
vagrant ssh mountain
