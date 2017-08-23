################################################################################
# Time-stamp: <Wed 2017-08-23 11:36 svarrette>
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
# This assumes the sources have been downloaded
#
# == Parameters
#
# @param ensure       [String]  Default: 'present'
#          Ensure the presence (or absence) of building
# @param version [String] Default: '17.02.7' (see params.pp)
#          Which version of Slurm to grab and build
# @param srcdir  [String] Default: '/usr/local/src'
#          Where the [downloaded] Slurm sources are located
# @param dir     [String] Default: '/root/rpmbuild' on redhat systems
#          Top directory of the sources builds (i.e. RPMs, debs...)
#          For instance, built RPMs will be placed under
#          <dir>/RPMS/${::architecture}
# @param with    [Array] Default: [ 'lua', ... ] -- see slurm::params
#          see https://github.com/SchedMD/slurm/blob/master/slurm.spec
#          List of --with build options to pass to rpmbuild
# @param without [Array] Default: [] -- see slurm::params
#          see https://github.com/SchedMD/slurm/blob/master/slurm.spec
#          List of --without build options to pass to rpmbuild
#
class slurm::build(
  String  $ensure       = $slurm::params::ensure,
  String  $version      = $slurm::params::version,
  String  $srcdir       = $slurm::params::srcdir,
  String  $dir          = $slurm::params::builddir,
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
