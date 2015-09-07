# puppet-module-swap
===

[![Build Status](https://travis-ci.org/Ericsson/puppet-module-swap.png?branch=master)](https://travis-ci.org/Ericsson/puppet-module-swap)

Puppet module to manage swap (swap files)

===

# Compatibility
---------------
This module is built for use with Puppet v3 on most Linux distributions.

===

# Parameters
------------

ensure
------
Ensure attribute for the swapfile

- *Default*: 'absent'

threshold_m
-----------
Reserved free space in megabytes (to avoid swap file consumes all the free space).

- *Default*: '2048'

swapfile_path
-------------
Swap file's full path

- *Default*: '/swapfile'

swapfile_size_m
---------------
Size of swap file in megabytes.

- *Default*: '1024'
