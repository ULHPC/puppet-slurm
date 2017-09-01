-*- mode: markdown; mode: visual-line;  -*-

# Slurm Puppet Module

[![Puppet Forge](http://img.shields.io/puppetforge/v/slurm.svg)](https://forge.puppet.com/ULHPC/slurm) [![License](http://img.shields.io/:license-Apache2.0-blue.svg)](LICENSE) ![Supported Platforms](http://img.shields.io/badge/platform-centos-lightgrey.svg) [![Documentation Status](https://readthedocs.org/projects/ulhpc-puppet-slurm/badge/?version=latest)](https://readthedocs.org/projects/ulhpc-puppet-slurm/?badge=latest)

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
|                            |                                                                                                                |

In addition, this puppet module implements several **private** classes:

* `slurm::common[::redhat]`: handles common tasks to all daemon
* `slurm::install`: install the Slurm packages, eventually built from downloaded sources
* `slurm::config[::{cgroup,gres,topology}]`: handles the various aspects of the configuration of SLURM daemons -- see <https://slurm.schedmd.com/slurm.conf.html#lbAN>
* `slurm::plugins::lua`: takes care of the Job Submit plugin 'lua' i.e. of the file [`job_submit.lua`](https://github.com/SchedMD/slurm/blob/master/contribs/lua/job_submit.lua).

All these components are configured through a set of variables you will find in [`manifests/params.pp`](manifests/params.pp).

_Note_: the various operations that can be conducted from this repository are piloted from a [`Rakefile`](https://github.com/ruby/rake) and assumes you have a running [Ruby](https://www.ruby-lang.org/en/) installation.
See `docs/contributing.md` for more details on the steps you shall follow to have this `Rakefile` working properly.


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

See [`metadata.json`](metadata.json). In particular, this module depends on

* [puppetlabs/stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib)

## Overview and Usage

### Class `slurm`

This is the main class defined in this module.
It accepts the following parameters:

* `$ensure`: default to 'present', can be 'absent'

Use it as follows:

     include ' slurm'

See also [`tests/init.pp`](tests/init.pp)



## Librarian-Puppet / R10K Setup

You can of course configure the slurm module in your `Puppetfile` to make it available with [Librarian puppet](http://librarian-puppet.com/) or
[r10k](https://github.com/adrienthebo/r10k) by adding the following entry:

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
