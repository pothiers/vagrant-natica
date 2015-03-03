echo "START: Provision valley and ssh to it."

vagrant provision valley --provision-with puppet
vagrant ssh valley
