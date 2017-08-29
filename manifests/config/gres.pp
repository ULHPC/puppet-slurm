################################################################################
# Time-stamp: <Tue 2017-08-29 14:24 svarrette>
#
# File::      <tt>config/gres.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# == Class: slurm::config::gres
#
# This PRIVATE class handles the Slurm configuration file for  generic resource
# management i.e. 'gres.conf'
#
# More details: see <https://slurm.schedmd.com/gres.conf.html>
#
class slurm::config::gres inherits slurm::config {

  $gres_content = $slurm::gres_content ? {
    undef   => $slurm::gres_source ? {
      undef   => $slurm::gres_target ? {
        undef   => template('slurm/gres.conf.erb'),
        default => $slurm::gres_content,
      },
    default => $slurm::gres_content
    },
  default => $slurm::gres_content,
  }
  $ensure = $slurm::gres_target ? {
    undef   => $slurm::ensure,
    default => 'link',
  }

  $gres_filename = "${slurm::configdir}/${slurm::params::gres_configfile}"

  # gres.conf
  file { $gres_filename:
    ensure  => $ensure,
    owner   => $slurm::username,
    group   => $slurm::group,
    mode    => $slurm::params::configfile_mode,
    content => $gres_content,
    source  => $slurm::gres_source,
    target  => $slurm::gres_target,
    notify  => $slurm::config::notify,
  }

}
