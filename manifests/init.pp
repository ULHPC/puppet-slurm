################################################################################
# Time-stamp: <Mon 2017-08-21 16:44 svarrette>
#
# File::      <tt>init.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# == Class: slurm
#
# The main slurm class, responsible for validating the parameters, and automate
# the provisioning and management of the daemons and compute nodes in a
# RedHat/CentOS based SLURM infrastructure.
# Slurm (A Highly Scalable Resource Manager) is an open source, fault-tolerant,
# and highly scalable cluster management and job scheduling system for large and
# small Linux clusters.
#
# More details on <https://slurm.schedmd.com/>
#
# === Parameters
#
# $ensure:: *Default*: 'present'. Ensure the presence (or absence) of slurm
#
#
# === Sample Usage
#
#     include 'slurm'
#
# You can then specialize the various aspects of the configuration,
# for instance
#
#         class { 'slurm':
  #             ensure => 'present'
  #         }
#
# === Authors
#
# The UL HPC Team <hpc-sysadmins@uni.lu> of the University of Luxembourg, in
# particular
# * Sebastien Varrette <Sebastien.Varrette@uni.lu>
# * Valentin Plugaru   <Valentin.Plugaru@uni.lu>
# * Sarah Peter        <Sarah.Peter@uni.lu>
# * Hyacinthe Cartiaux <Hyacinthe.Cartiaux@uni.lu>
# * Clement Parisot    <Clement.Parisot@uni.lu>
#
# === Warnings
#
# /!\ Always respect the style guide available here[http://docs.puppetlabs.com/guides/style_guide]
#
# [Remember: No empty lines between comments and class definition]
#
class slurm(
  String  $ensure            = $slurm::params::ensure,
  Integer $uid               = $slurm::params::uid,
  Integer $gid               = $slurm::params::gid,
  String  $auth_type         = $slurm::params::auth_type,
  Integer $munge_uid         = $slurm::params::munge_uid,
  Integer $munge_gid         = $slurm::params::munge_gid,
  Boolean $use_pam           = $slurm::params::use_pam,
  String  $pam_content       = $slurm::params::pam_content,
  String  $pam_limits_source = $slurm::params::pam_limits_source,
)
inherits slurm::params
{
  validate_legacy('String', 'validate_re', $ensure, ['^present', '^absent'])

  info ("Configuring SLURM (with ensure = ${ensure})")

  case $::operatingsystem {
    #debian, ubuntu:         { include ::slurm::common::debian }
    'redhat', 'fedora', 'centos': { include ::slurm::common::redhat }
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }
}
