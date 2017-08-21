################################################################################
# Time-stamp: <Mon 2017-08-21 17:31 svarrette>
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
  String $ensure        = $slurm::params::ensure,
)
inherits slurm::params
{
  validate_legacy('String', 'validate_re', $ensure, ['^present', '^absent'])

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
    gid    => $slurm::params::munge_gid,
  }
  user { 'munge':
    ensure => $ensure,
    uid    => $slurm::params::munge_uid,
    gid    => $slurm::params::munge_gid,
  }






}
