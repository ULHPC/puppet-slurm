-*- mode: markdown; mode: visual-line;  -*-

# Slurm Puppet Module

[![Puppet Forge](http://img.shields.io/puppetforge/v/ULHPC/slurm.svg)](https://forge.puppet.com/ULHPC/slurm) [![License](http://img.shields.io/:license-Apache2.0-blue.svg)](LICENSE) ![Supported Platforms](http://img.shields.io/badge/platform-centos-lightgrey.svg) [![Documentation Status](https://readthedocs.org/projects/ulhpc-puppet-slurm/badge/?version=latest)](http://ulhpc-puppet-slurm.readthedocs.io)

Configure and manage [Slurm](https://slurm.schedmd.com/): A Highly Scalable Resource Manager

      Copyright (c) 2017 UL HPC Team <hpc-sysadmins@uni.lu>
      .             see also http://hpc.uni.lu

## Overview

[Slurm](https://slurm.schedmd.com/) (aka "Simple Linux Utility for Resource Management") is a free and open-source job scheduler for Linux and Unix-like kernels, used by many of the world's supercomputers and computer clusters (~60% of Top500 rely on it).

> Slurm is an open source, fault-tolerant, and highly scalable cluster management and job scheduling system for large and small Linux clusters

It provides three key functions.

1. it allocates exclusive and/or non-exclusive access to resources (computer nodes) to users for some duration of time so they can perform work.
2. it provides a framework for starting, executing, and monitoring work (typically a parallel job such as MPI) on a set of allocated nodes.
3. Finally, it arbitrates contention for resources by managing a queue of pending jobs.

This [Puppet](https://puppet.com/) module is designed to configure and manage the
different daemons and components of a typical Slurm architecture, depicted below:

![](https://slurm.schedmd.com/arch.gif)

In particular, this module implements the following elements:

| Puppet Class       | Description                                                                                                          |
|--------------------|----------------------------------------------------------------------------------------------------------------------|
| `slurm`            | The main slurm class, piloting all aspects of the configuration                                                      |
| `slurm::slurmdbd`  | Specialized class for [Slurmdbd](https://slurm.schedmd.com/slurmdbd.html), the Slurm Database Daemon.                |
| `slurm::slurmctld` | Specialized class for [Slurmctld](https://slurm.schedmd.com/slurmctld.html), the central management daemon of Slurm. |
| `slurm::slurmd`    | Specialized class for [Slurmd](https://slurm.schedmd.com/slurmd.html), the compute node daemon for Slurm.            |
| `slurm::munge`     | Manages [MUNGE]( https://github.com/dun/munge), an authentication service for creating and validating credentials.   |
| `slurm::pam`       | Handle PAM aspects  for SLURM (Memlock for MPI etc.)                                                                 |

| Puppet Defines             | Description                                                                                                    |
|----------------------------|----------------------------------------------------------------------------------------------------------------|
| `slurm::download`          | takes care of downloading the SLURM sources for a given version  passed as resource name                       |
| `slurm::build`             | building Slurm sources into packages (_i.e. RPMs for the moment) for a given version  passed as resource name  |
| `slurm::install::packages` | installs the Slurm packages, typically built from `slurm::build`, for a given version passed as resource name. |
| `slurm::acct::cluster`     | adding (or removing) a cluster to the slurm database                                                           |

In addition, this puppet module implements several **private** classes:

* `slurm::common[::redhat]`: handles common tasks to all daemon
* `slurm::install`: install the Slurm packages, eventually built from downloaded sources
* `slurm::config[::{cgroup,gres,topology}]`: handles the various aspects of the configuration of SLURM daemons -- see <https://slurm.schedmd.com/slurm.conf.html#lbAN>
* `slurm::plugins::lua`: takes care of the Job Submit plugin 'lua' i.e. of the file [`job_submit.lua`](https://github.com/SchedMD/slurm/blob/master/contribs/lua/job_submit.lua).

All these components are configured through a set of variables you will find in [`manifests/params.pp`](https://github.com/ULHPC/puppet-slurm/blob/devel/manifests/params.pp).

_Note_: the various operations that can be conducted from this repository are piloted from a [`Rakefile`](https://github.com/ruby/rake) and assumes you have a running [Ruby](https://www.ruby-lang.org/en/) installation.
See `docs/contributing.md` for more details on the steps you shall follow to have this `Rakefile` working properly.

**IMPORTANT** Until the release of version 1.0 (denoting a usage in production on the [UL HPC Platform](http://hpc.uni.lu)), **this module is still to be considered in alpha state and a work in progress**. Use it at your own risks!

### Setup Requirements

This module currently only works completely on Redhat / CentOS 7 over Puppet 4.x.
Over operating systems and support for Puppet 5.x will eventually be added.
Yet feel free to contribute to this module to help us extending the usage of this module.

By default, some key configuration decisions are configured, namely:

* [MUNGE](https://github.com/dun/munge) is used for shared key authentication.
     - the shared key is generated by default, but you probably want to provide it to puppet via a URI.
* None of the daemons are configured by default.
     - You have to set the boolean parameter(s) `with_{slurmdbd,slurmctl,slurmd}` to `true` and/or include explicitly the `slurm::{slurmdbd,slurmctld,slurmd}` classes


## Forge Module Dependencies

See [`metadata.json`](https://github.com/ULHPC/puppet-slurm/blob/devel/metadata.json). In particular, this module depends on

* [puppetlabs/stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib)
* [puppetlabs/mysql](https://forge.puppetlabs.com/puppetlabs/mysql)
* [puppetlabs/inifile](https://forge.puppetlabs.com/puppetlabs/inifile)
* [puppet/archive](https://forge.puppetlabs.com/puppet/archive)
* [puppet/yum](https://forge.puppetlabs.com/puppet/yum)
* [stahnma/epel](https://forge.puppetlabs.com/stahnma/epel)
* [bodgit/rngd](https://forge.puppetlabs.com/bodgit/rngd)
* [ghoneycutt/pam](https://forge.puppetlabs.com/ghoneycutt/pam)

## Overview and Usage

### Class `slurm`

This is the main class defined in this module.
It accepts so many parameters that they are not listed here -- see the [puppet strings `@param`] comments of [`manifests/init.pp`](https://github.com/ULHPC/puppet-slurm/blob/devel/manifests/init.pp)
Use it as follows:

```ruby
include ::slurm
```

See also [`tests/init.pp`](https://github.com/ULHPC/puppet-slurm/blob/devel/tests/init.pp) or a more advanced usage (defining the network topology, the computing nodes and the SLURM partitions) in [`tests/advanced.pp`](https://github.com/ULHPC/puppet-slurm/blob/devel/tests/advanced.pp)

### Class `slurm::slurmdbd`

This class is responsible for setting up a [Slurm Database Daemon](https://slurm.schedmd.com/slurmdbd.html), which provides a secure enterprise-wide interface to a database for Slurm.
In particular, it can run relatively independently of the other slurm daemon instances and thus is proposed as a separate independent class.

You can simply configure it as follows:

```ruby
include ::slurm
include ::slurm::slurmdbd
```

Alternatively, you can use the `with_slurdbd` parameter of the `::slurm` class:

```ruby
class { '::slurm':
    with_slurmdbd => true,
}
```

See also [`tests/slurmdbd.pp`](tests/slurmdbd.pp)

The `slurm::slurmdbd` accepts also so many parameters that they are not listed here -- see the [puppet strings `@param`] comments of [`manifests/slurmdbd.pp`](https://github.com/ULHPC/puppet-slurm/blob/devel/manifests/slurmddbd.pp) for more details

### Class `slurm::slurmctld`

The main helper class specializing the main slurm class for setting up a Slurmctld daemon aka the slurm controller.

```ruby
include ::slurm
include ::slurm::slurmctld
```

Alternatively, you can use the `with_slurctld` parameter of the `::slurm` class:

```ruby
class { '::slurm':
    with_slurmctld => true,
}
```

### Class `slurm::slurmd`

The main helper class specializing the main slurm class for setting up a Slurmctld daemon aka the slurm controller.

```ruby
include ::slurm
include ::slurm::slurmctld
```

Alternatively, you can use the `with_slurd` parameter of the `::slurm` class:

```ruby
class { '::slurm':
    with_slurmd => true,
}
```

There are of course *many* configuration parameters that you can set to change the content of the `slurm.conf` configuration file (generated from the ERB template).
Read the documentation of the `slurm` class to make them suit your tastes and wishes.

### Class `slurm::munge`

[MUNGE](https://github.com/dun/munge) (MUNGE Uid 'N' Gid Emporium) is an authentication service for creating and validating credentials. It is designed to be highly scalable for use in an HPC cluster environment.
It allows a process to authenticate the UID and GID of another local or remote process within a group of hosts having common users and groups. These hosts form a security realm that is defined by a shared cryptographic key.
Clients within this security realm can create and validate credentials without the use of root privileges, reserved ports, or platform-specific methods.

For more information, see <https://github.com/dun/munge>

The puppet class `slurm::munge` is thus responsible for setting up a working Munge environment to
be used by the SLURM daemons -- see also <https://slurm.schedmd.com/authplugins.html>
Use it as follows:

```ruby
include ::slurm::munge
```

Or, if you wish to provide the munge key using puppet URI:

```ruby
class {'::slurm::munge':
    ensure     => true,
    key_source => "puppet:///modules/${myprofile}/munge.key"
}
```

If, as in the above example, the key is stored centrally in your control repository, you probably want to store it encrypted using [git-crypt](https://github.com/AGWA/git-crypt) for instance.

The `slurm::munge` class accepts the following parameters:

* `ensure`  [String]  Default: 'present'
   - Ensure the presence (or absence) of the Munge service
* `create_key`   [Boolean] Default: true
   - Whether or not to generate a new key if it does not exists
* `daemon_args`  [Array] Default: []
   - Set the content of the DAEMON_ARGS variable, which permits to set additional command-line options to the daemon. For example, this can be used to override the location of the secret key (`--key-file`) or  set the number of worker threads (`--num-threads`) See <https://github.com/dun/munge/wiki/Installation-Guide#starting-the-daemon>.
* `gid` [Integer] Default: 992
   - GID of the munge group
* `key_content`  [String] Default: undef
   - The desired contents of a file, as a string. This attribute is mutually exclusive with source and target.
* `key_filename` [String] Default: '/etc/munge/munge.key'
   - The secret key filename
* `key_source`   [String] Default: undef
   - A source file, which will be copied into place on the local system. This attribute is mutually exclusive with content. The normal form of a puppet: URI is `puppet:///modules/<MODULE NAME>/<FILE PATH>`
* `uid` [Integer] Default: 992
   - UID of the munge user

Note that the `slurm` class makes use of this class by default as the parameter `manage_munge` is set to true by default.

### Definition `slurm::download`

This definition takes care of downloading the SLURM sources for a given version (passed as name to this resource) and placing them into `$target` directory. You can also invoke this definition with the full archive filename i.e. `slurm-<version>.tar.bz2`.

* `ensure` [String]  Default: `present`
     - Ensure the presence (or absence) of building
* `target` [String] Default: `/usr/local/src`
     - Target directory for the downloaded sources
* `archived` [Boolean] Default: `false`
     - Whether the sources tar.bz2 has been archived or not.Thus by default, it is assumed that the provided version is the latest version (from <https://www.schedmd.com/downloads/latest/>).
     - If set to `true`, the sources will be download from <https://www.schedmd.com/downloads/archive/>
* `checksum_type` [String] Default: `md5`
     - archive file checksum type (none|md5|sha1|sha2|sh256|sha384| sha512).
* `checksum_verify` [Boolean] Default: false
     - whether checksum will be verified (true|false).
* `checksum` [String] Default: ''
     -  archive file checksum (match checksum_type)

_Example 1_: Downloading version 17.06.7 (latest at the time of writing) of SLURM

```ruby
slurm::download { '17.02.7':
  ensure    => 'present',
  checksum  => '64009c1ed120b9ce5d79424dca743a06',
  target    => '/usr/local/src/',
}
```

_Example 2_: Downloading archived version 16.05.10 version of SLURM

```ruby
slurm::download { 'slurm-16.05.10.tar.bz2':
  ensure   => 'present',
  archived => true,
  target   => '/usr/local/src/',
}
```

### Definition `slurm::build`

This definition takes care of building Slurm sources into RPMs using 'rpmbuild'.
It expect to get as resource name the SLURM version to build
This assumes the sources have been downloaded using slurm::download


* `ensure`  [String]  Default: `present`
     - Ensure the presence (or absence) of building
* `srcdir`  [String] Default: `/usr/local/src`
     - Where the [downloaded] Slurm sources are located
* `dir`     [String] Default: `/root/rpmbuild` on redhat systems
     - Top directory of the sources builds (i.e. RPMs, debs...). For instance, built RPMs will be placed under `${dir}/RPMS/${::architecture}`
* `with`    [Array] Default: `[ 'lua', ... ]`
     - List of --with build options to pass to rpmbuild -- see <https://github.com/SchedMD/slurm/blob/master/slurm.spec>
* `without` [Array] Default: `[]`
     - List of --without build options to pass to rpmbuild -- see <https://github.com/SchedMD/slurm/blob/master/slurm.spec>


_Example_: Building version 17.06.7 (latest at the time of writing)  of SLURM

```ruby
slurm::build { '17.02.7':
  ensure => 'present',
  srcdir => '/usr/local/src',
  dir    => '/root/rpmbuild',
  with   => [ 'lua', 'mysql', 'openssl' ]
}
```

### Definition `slurm::install::packages`

This definition takes care of installing the Slurm packages, typically built from `slurm::build`, for a given version passed as resource name.

_Example_: installing slurmd packages in version 17.02.7:

```ruby
slurm::install::packages { '17.02.7':
   ensure => 'present',
   pkgdir => "/root/rpmbuild/RPMs/${::architecture}",
   slurmd => true
}
```


## Librarian-Puppet / R10K Setup

You can of course configure the slurm module in your `Puppetfile` to make it available with [Librarian puppet](http://librarian-puppet.com/) or [r10k](https://github.com/adrienthebo/r10k) by adding the following entry:

     # Modules from the Puppet Forge
     mod "ULHPC/slurm"

or, if you prefer to work on the git version:

     mod "ULHPC/slurm",
         :git => 'https://github.com/ULHPC/puppet-slurm',
         :ref => 'production'

## Issues / Feature request

You can submit bug / issues / feature request using the [slurm Puppet Module Tracker](https://github.com/ULHPC/puppet-slurm/issues).

## Developments / Contributing to the code

If you want to contribute to the code, you shall be aware of the way this module is organized.
These elements are detailed on [`docs/contributing.md`](contributing/index.md).

You are more than welcome to contribute to its development by [sending a pull request](https://help.github.com/articles/using-pull-requests).

## Puppet modules tests within a Vagrant box

The best way to test this module in a non-intrusive way is to rely on [Vagrant](http://www.vagrantup.com/).
The `Vagrantfile` at the root of the repository pilot the provisioning various vagrant boxes available on [Vagrant cloud](https://atlas.hashicorp.com/boxes/search?utf8=%E2%9C%93&sort=&provider=virtualbox&q=svarrette) you can use to test this module.

See [`docs/vagrant.md`](vagrant.md) for more details.

## Online Documentation

[Read the Docs](https://readthedocs.org/) aka RTFD hosts documentation for the open source community and the [slurm](https://github.com/ULHPC/puppet-slurm) puppet module has its documentation (see the `docs/` directly) hosted on [readthedocs](http://ulhpc-puppet-slurm.rtfd.org).

See [`docs/rtfd.md`](rtfd.md) for more details.

## Licence

This project and the sources proposed within this repository are released under the terms of the [Apache-2.0](LICENCE) licence.


[![Licence](https://www.apache.org/images/feather-small.gif)](LICENSE)
