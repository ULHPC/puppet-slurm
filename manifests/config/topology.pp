################################################################################
# Time-stamp: <Wed 2017-08-30 11:59 svarrette>
#
# File::      <tt>config/topology.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# == Class: slurm::config::topology
#
# This PRIVATE class handles the Slurm configuration file for defining the network
# topology  i.e. 'topology.conf'
#
# More details: see <https://slurm.schedmd.com/topology.conf.html>
#
class slurm::config::topology inherits slurm::config {

  $topology_content = $slurm::topology_content ? {
    undef   => $slurm::topology_source ? {
      undef   => $slurm::topology_target ? {
        undef   => template('slurm/topology.conf.erb'),
        default => $slurm::topology_content,
      },
    default => $slurm::topology_content
    },
  default => $slurm::topology_content,
  }
  $ensure = $slurm::topology_target ? {
    undef   => $slurm::ensure,
    default => 'link',
  }
  $topology_filename = "${slurm::configdir}/${slurm::params::topology_configfile}"

  if  $slurm::topology == 'tree' {
    file { $topology_filename:
      ensure  => $ensure,
      owner   => $slurm::username,
      group   => $slurm::group,
      mode    => $slurm::params::configfile_mode,
      content => $topology_content,
      source  => $slurm::topology_source,
      target  => $slurm::topology_target,
      tag     => 'slurm::configfile',
      require => File[$slurm::configdir],
    }
  }



}
