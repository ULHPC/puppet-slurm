################################################################################
# Time-stamp: <Mon 2017-09-04 14:44 svarrette>
#
# File::      <tt>acct/cluster.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Defines: slurm::acct::cluster
#
# This definition takes care of adding (or removing) a cluster to the slurm database.
# /!\ WARNING: this assumes you are using the MySQL plugin as SlurmDBD plugin and a working SLURMDBD.
# The name of this resource is expected to be the cluster name.
#
# @param ensure [String]  Default: 'present'
#          Ensure the presence (or absence) of the cluster
#
# @example Adding the cluster 'thor' to Slurm
#
#     slurm::acct::cluster { 'thor':
  #     ensure    => 'present',
  #   }
#
#
define slurm::acct::cluster(
  String  $ensure = $slurm::ensure,
)
{
  include ::slurm
  include ::slurm::params
  validate_legacy('String',  'validate_re',   $ensure, ['^present', '^absent'])

  # $name is provided at define invocation
  $clustername = $name

  $action = $ensure ? {
    'absent' => 'del',
    default  => 'add',
  }

  case $ensure {
    'absent': {
      $label        = "delete-${clustername}"
      $cmd          = "sacctmgr -i del cluster ${clustername}"
      $check_onlyif = undef
      $check_unless = undef
    }
    default: {
      $label        = "add-${clustername}"
      $cmd          = "sacctmgr -i add cluster ${clustername}"
      $check_onlyif = 'test -z "$(sacctmgr --noheader -p list cluster)"'
      $check_unless = "test -n \"$(sacctmgr --noheader -p list cluster | grep ${clustername})\""
    }
  }
  #notice($cmd)
  exec { $label:
    path    => '/sbin:/usr/bin:/usr/sbin:/bin',
    command => $cmd,
    onlyif  => $check_onlyif,
    unless  => $check_unless,
  }
}
