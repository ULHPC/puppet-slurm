################################################################################
# Time-stamp: <Tue 2017-08-22 16:13 svarrette>
#
# File::      <tt>build.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Class: slurm::build
#
# This class takes care of building Slurm sources into RPMs using 'rpmbuild'.
#
# == Parameters
#
# @param ensure       [String]  Default: 'present'
#        Ensure the presence (or absence) of building
#
#
class slurm::build(
  String  $ensure       = $slurm::params::ensure,
  String  $version      = $slurm::params::version,
  Boolean $src_archived = $slurm::params::src_archived,
  String  $srcdir       = $slurm::params::srcdir,
  String  $builddir     = $slurm::params::builddir,
  Array   $with         = $slurm::params::build_with,
  Array   $without      = $slurm::params::build_without,
)
inherits slurm::params
{
  validate_legacy('String',  'validate_re',   $ensure, ['^present', '^absent'])

  case $::osfamily {
    #debian, ubuntu:         { include ::slurm::build::debian }
    'RedHat': { include ::slurm::build::redhat }
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }
}
