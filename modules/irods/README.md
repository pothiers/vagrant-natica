# irods

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with irods](#setup)
    * [What irods affects](#what-irods-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with irods](#beginning-with-irods)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Install and configure irods. see: https://github.com/irods/irods
Works with CentOS 6.5, maybe others.  Uses Puppet 3.7.1

## Module Description

Installs and configures iRODS from RPMs.
Integrates with Postgresql. After a new VM is created and this module
successfull used, you can run iCommands as "irods" user.
e.g. '/bin/su - irods -c ils'



## Setup

### What irods affects

* Loads packages irods needs plus postgres:
* Setups up and starts the postgres DB for use with irods
* Modifies firewall settings to allow irods connections (TCP, UDP)
* Starts the iRODS server

__WARNING: Blindly feeds answers to *setup_irods.sh* prompts.__
The *setup_irods.sh* script comes from the irods RPMs. If the precise
order or count of prompts is issues changes at all, this will break!
  

### Setup Requirements **OPTIONAL**

If your module requires anything extra before setting up (pluginsync enabled,
etc.), mention it here.

### Beginning with irods

```puppet
class { 'irods':
  setup_input_file =>  '/vagrant/modules/irods/setup_irods.input',
}
```


## Usage

```puppet
class { 'irods':
  setup_input_file =>  '/vagrant/modules/irods/setup_irods.input',
  dbuser           => 'irods',
  dbpass           => 'irods-temppasswd',
}
```

## Reference

Here, list the classes, types, providers, facts, etc contained in your module.
This section should include all of the under-the-hood workings of your module so
people know what the module is touching on their system but don't need to mess
with things. (We are working on automating this section!)

* Classes
  * firewall
  * irods_fw::pre
  * irods_fw::post
  * postgresql::server::db
* Resources
  * firewall
* Packages
  * Dependencies
    * postgresql-odbc
    * unixODBC
    * authd
    * fuse-libs
    * openssl098e
  * iRODS (4.0.3)
    * irods-icat
    * irods-runtime
    * irods-icommands
    * irods-database-plugin-postgres
  * postgresql
* Exec
  * of setup_irods.sh from irods packages


## Limitations

* Gets iRODS RPMs directly from ftp://ftp.renci.org/pub/irods/releases/4.0.3


