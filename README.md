# puppet-module-swap
===

[![Build Status](https://travis-ci.org/Ericsson/puppet-module-swap.png?branch=master)](https://travis-ci.org/Ericsson/puppet-module-swap)

Puppet module to manage swap (swap files)

===

# Compatibility
---------------
This module is built for use with Puppet v3 on the following OS families.

* EL 5
* EL 6
* Suse SLE10
* Suse SLE11

===

# Parameters
------------

ensure
------
Ensure attribute for the swapfile

- *Default*: 'present'

size_m
------
The swapfile size in megabytes

- *Default*: '1024'

swapfile_path
-------------
Swap file's full path

- *Default*: '/swapfile'
