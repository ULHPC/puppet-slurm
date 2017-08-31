################################################################################
# Time-stamp: <Thu 2017-08-31 14:29 svarrette>
#
# File::      <tt>slurmd.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# == Class: slurm::slurmd
#
# The main helper class specializing the main slurm class for setting up a
# Slurmd daemon
#
# === Warnings
#
# /!\ Always respect the style guide available here[http://docs.puppetlabs.com/guides/style_guide]
#
# [Remember: No empty lines between comments and class definition]
#
class slurm::slurmd inherits slurm
{
  File <| tag == 'slurm::configfile' |> {
    notify  +> Service['slurmd'],
  }

  service { 'slurmd':
    ensure     => ($slurm::ensure == 'present'),
    enable     => ($slurm::ensure == 'present'),
    name       => $slurm::params::servicename,
    pattern    => $slurm::params::processname,
    hasrestart => $slurm::params::hasrestart,
    hasstatus  => $slurm::params::hasstatus,
    require    => Class['::slurm::config'],
  }

  if defined(Class['::slurm::slurmctld']) {
    Service['slurmctld'] -> Service['slurmd']
  }
}
