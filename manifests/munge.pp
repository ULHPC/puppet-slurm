################################################################################
# Time-stamp: <Mon 2017-08-21 21:38 svarrette>
#
# File::      <tt>munge.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Class: slurm::munge
#
# MUNGE (MUNGE Uid 'N' Gid Emporium) is an authentication service for creating
# and validating credentials. It is designed to be highly scalable for use in an
# HPC cluster environment.
#  It allows a process to authenticate the UID and GID of another local or
# remote process within a group of hosts having common users and groups. These
# hosts form a security realm that is defined by a shared cryptographic key.
# Clients within this security realm can create and validate credentials without
# the use of root privileges, reserved ports, or platform-specific methods.
#
# For more information, see https://github.com/dun/munge
#
# This Puppet class is responsible for setting up a working Munge environment to
# be used by the SLURM daemons.
#
# See https://slurm.schedmd.com/authplugins.html
#
# == Parameters
#
# @param ensure  [String]  Default: 'present'
#        Ensure the presence (or absence) of sysctl
#
# /!\ We assume the RPM 'slurm-munge' has been already installed -- this class
# does not care about it

class slurm::munge(
  String $ensure       = $slurm::params::ensure,
  Boolean $create_key  = $slurm::params::munge_create_key,
  String $key_filename = $slurm::params::munge_key,
  $key_source          = undef,
  $key_content         = undef,
)
inherits slurm::params
{
  validate_legacy('String',  'validate_re',   $ensure, ['^present', '^absent'])
  validate_legacy('Boolean', 'validate_bool', $create_key)

  if ($::osfamily == 'RedHat') {
    include ::epel
  }

  # Order
  if ($ensure == 'present')
  { Group['munge'] -> User['munge'] -> Package['munge'] }
  else
  { Package['munge'] -> User['munge'] -> Group['munge'] }


  # Install the required packages
  package { 'munge':
    ensure => $ensure,
    name   => $slurm::params::munge_package,
  }
  package { $slurm::params::munge_extra_packages:
    ensure  => $ensure,
    require => Package['munge'],
  }

  # Prepare the user and group
  group { 'munge':
    ensure => $ensure,
    name   => $slurm::params::group,
    gid    => $slurm::params::munge_gid,
  }
  user { 'munge':
    ensure     => $ensure,
    name       => $slurm::params::munge_username,
    uid        => $slurm::params::munge_uid,
    gid        => $slurm::params::munge_gid,
    comment    => $slurm::params::munge_comment,
    home       => $slurm::params::munge_home,
    managehome => true,
    system     => true,
    shell      => '/sbin/nologin',
  }

  if $ensure == 'present' {
    file { [ "${slurm::params::munge_configdir}", "${slurm::params::munge_logdir}" ]:
      ensure => 'directory',
      owner  => "${slurm::params::munge_username}",
      group  => "${slurm::params::munge_group}",
      mode   => "0700",
      require => Package['munge'],
    }
    file { "${slurm::params::munge_piddir}":
      ensure => 'directory',
      owner  => "${slurm::params::munge_username}",
      group  => "${slurm::params::munge_group}",
      mode   => "0755",
      require => Package['munge'],
    }
  }
  else {
    file {
      [
        "${slurm::params::munge_configdir}",
        "${slurm::params::munge_logdir}",
        "${slurm::params::munge_piddir}"
      ]:
        ensure => $ensure,
        force  => true
    }
  }

  # Create the key if needed
  if ($create_key and $ensure == 'present') {
    class { '::rngd':
      hwrng_device => '/dev/urandom',
    }
    exec { "create Munge key ${slurm::params::munge_key}":
      path    => '/sbin:/usr/bin:/usr/sbin:/bin',
      command => "dd if=/dev/urandom bs=1 count=1024 > ${key_filename}", # OR "create-munge-key",
      unless  => "test -f ${key_filename}",
      user    => 'root',
      before  => File["${key_filename}"],
      require => [
        File[dirname($key_filename)],
        Package['munge'],
        Class['::rngd']
      ],
    }
  }
  # ensure the munge key /etc/munge/munge.key
  file { $key_filename:
    ensure => $ensure,
    owner   => "${slurm::params::munge_username}",
    group   => "${slurm::params::munge_group}",
    mode    => '0400',
    content => $key_content,
    source  => $key_source
  }

  # Run munge service
  service { 'munge':
    name       => "${slurm::params::munge_servicename}",
    enable     => ($ensure == 'present'),
    ensure     => ($ensure == 'present'),
    pattern    => "${slurm::params::munge_processname}",
    hasrestart => "${slurm::params::hasrestart}",
    hasstatus  => "${slurm::params::hasstatus}",
    require    => [
      Package['munge'],
      File["${key_filename}"],
      File["${slurm::params::munge_configdir}"],
      File["${slurm::params::munge_logdir}"],
      File["${slurm::params::munge_piddir}"]
    ],
    subscribe  => File["${key_filename}"]
  }





}
