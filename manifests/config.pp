################################################################################
# Time-stamp: <Thu 2017-08-24 18:16 svarrette>
#
# File::      <tt>config.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# == Class: slurm::config
#
# This PRIVATE class handles the configuration of SLURM daemons
# More details on <https://slurm.schedmd.com/slurm.conf.html#lbAN> and also on
# - https://slurm.schedmd.com/slurm.conf.html
# - https://slurm.schedmd.com/slurmdbd.conf.html
# - https://slurm.schedmd.com/topology.conf.html
# - https://slurm.schedmd.com/cgroup.conf.html
#
class slurm::config inherits slurm {

  file { $slurm::configdir:
    ensure => 'directory',
    owner  => $slurm::params::configdir_owner,
    group  => $slurm::params::configdir_group,
    mode   => $slurm::params::configdir_mode,
  }

  include ::slurm::config::cgroup
  include ::slurm::config::gres
  include ::slurm::config::topology

  # Now let's deal with slurm.conf
  $slurm_content = $slurm::content ? {
    undef   => $slurm::source ? {
      undef   => $slurm::target ? {
        undef   => template('slurm/slurm.conf.erb'),
        default => $slurm::content,
      },
    default => $slurm::content
    },
  default => $slurm::content,
  }
  $ensure = $slurm::target ? {
    undef   => $slurm::ensure,
    default => 'link',
  }

  $filename = "${slurm::configdir}/${slurm::params::configfile}"

  file { $cgroup_filename:
    ensure  => $ensure,
    owner   => $slurm::username,
    group   => $slurm::group,
    mode    => $slurm::params::configfile_mode,
    content => $content,
    source  => $slurm::source,
    target  => $slurm::target,
  }



}
