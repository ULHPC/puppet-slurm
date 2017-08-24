################################################################################
# Time-stamp: <Thu 2017-08-24 21:36 svarrette>
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
# @param ensure [String] Default: 'present'.
#         Ensure the presence (or absence) of slurm
# @param content [String]
#          The desired contents of a file, as a string. This attribute is
#          mutually exclusive with source and target.
#          See also
#          https://docs.puppet.com/puppet/latest/types/file.html#file-attribute-content
# @param source  [String]
#          A source file, which will be copied into place on the local system.
#          This attribute is mutually exclusive with content and target.
#          See also
#          https://docs.puppet.com/puppet/latest/types/file.html#file-attribute-source
# @param target  [String]
#          See also
#          https://docs.puppet.com/puppet/latest/types/file.html#file-attribute-target
#
# @example Default instance
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
  String  $ensure         = $slurm::params::ensure,
  Integer $uid            = $slurm::params::uid,
  Integer $gid            = $slurm::params::gid,
  String  $version        = $slurm::params::version,
  Boolean $with_slurmd    = $slurm::params::with_slurmd,
  Boolean $with_slurmctld = $slurm::params::with_slurmctld,
  Boolean $with_slurmdbd  = $slurm::params::with_slurmdbd,
  Array   $wrappers       = $slurm::params::wrappers,
  #
  # Main configuration paramaters
  #
  String  $configdir        = $slurm::params::configdir,
  String  $clustername      = $slurm::params::clustername,
  String  $authtype         = $slurm::params::authtype,
  String  $authinfo         = $slurm::params::authinfo,
  String  $controlmachine   = $slurm::params::controlmachine,
  String  $controladdr      = $slurm::params::controladdr,
  String  $backupcontroller = $slurm::params::backupcontroller,
  String  $backupaddr       = $slurm::params::backupaddr,




  String  $topology        = $slurm::params::topology,

  #
  # cgroup.conf
  #
  $cgroup_content                    = undef,
  $cgroup_source                     = undef,
  $cgroup_target                     = undef,
  Boolean $cgroup_automount          = $slurm::params::cgroup_automount,
  String  $cgroup_mountpoint         = $slurm::params::cgroup_mountpoint,
  Array   $cgroup_alloweddevices     = $slurm::params::cgroup_alloweddevices,
  $cgroup_allowedkmemspace           = $slurm::params::cgroup_allowedkmemspace,
  Numeric $cgroup_allowedramspace    = $slurm::params::cgroup_allowedramspace,
  Numeric $cgroup_allowedswapspace   = $slurm::params::cgroup_allowedswapspace,
  Boolean $cgroup_constraincores     = $slurm::params::cgroup_constraincores,
  Boolean $cgroup_constraindevices   = $slurm::params::cgroup_constraindevices,
  Boolean $cgroup_constrainkmemspace = $slurm::params::cgroup_constrainkmemspace,
  Boolean $cgroup_constrainramspace  = $slurm::params::cgroup_constrainramspace,
  Boolean $cgroup_constrainswapspace = $slurm::params::cgroup_constrainswapspace,
  Numeric $cgroup_maxrampercent      = $slurm::params::cgroup_maxrampercent,
  Numeric $cgroup_maxswappercent     = $slurm::params::cgroup_maxswappercent,
  Numeric $cgroup_maxkmempercent     = $slurm::params::cgroup_maxkmempercent,
  String  $cgroup_minkmemspace       = $slurm::params::cgroup_minkmemspace,
  String  $cgroup_minramspace        = $slurm::params::cgroup_minramspace,
  Boolean $cgroup_taskaffinity       = $slurm::params::cgroup_taskaffinity,
  #
  # gres.conf
  #
  $gres_content  = undef,
  $gres_source   = undef,
  $gres_target   = undef,
  Hash    $gres  = {},
  #
  # topology.conf
  #
  $topology_content      = undef,
  $topology_source       = undef,
  $topology_target       = undef,
  Hash    $topology_tree = {},
  #
  # Slurm source building
  # TODO: option NOT to build but re-use shared RPMs
  Boolean $src_archived  = $slurm::params::src_archived,
  String  $src_checksum  = $slurm::params::src_checksum,
  String  $srcdir        = $slurm::params::srcdir,
  String  $builddir      = $slurm::params::builddir,
  #
  # Munge authentication service
  #
  Boolean $use_munge          = $slurm::params::use_munge,
  Boolean $munge_create_key   = $slurm::params::munge_create_key,
  Array   $munge_daemon_args  = $slurm::params::munge_daemon_args,
  $munge_key_source           = undef,
  $munge_key_content          = undef,
  String  $munge_key_filename = $slurm::params::munge_key,
  Integer $munge_uid          = $slurm::params::munge_uid,
  Integer $munge_gid          = $slurm::params::munge_gid,
  #
  # PAM settings
  #
  Boolean $use_pam             = $slurm::params::use_pam,
  String  $pam_content         = $slurm::params::pam_content,
  Array   $pam_allowed_users   = $slurm::params::pam_allowed_users,
  String  $pam_limits_source   = $slurm::params::pam_limits_source,
  Boolean $use_pam_slurm_adopt = $slurm::params::use_pam_slurm_adopt,
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
