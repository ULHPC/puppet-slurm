################################################################################
# Time-stamp: <Fri 2017-09-01 10:56 svarrette>
#
# File::      <tt>slurmctld.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# == Class: slurm::slurmctld
#
# The main helper class specializing the main slurm class for setting up a
# Slurmctld daemon aka the slurm controller
#
# === Warnings
#
# /!\ Always respect the style guide available here[http://docs.puppetlabs.com/guides/style_guide]
#
# [Remember: No empty lines between comments and class definition]
#
class slurm::slurmctld inherits slurm
{
  case $::osfamily {
    'Redhat': { }
    default:  { fail("Module ${module_name} is not supported on ${::operatingsystem}") }
  }

  include ::slurm::install
  include ::slurm::config

  File <| tag == 'slurm::configfile' |> {
    notify  +> Service['slurmctld'],
  }

  service { 'slurmctld':
    ensure     => ($slurm::ensure == 'present'),
    enable     => ($slurm::ensure == 'present'),
    name       => $slurm::params::controller_servicename,
    pattern    => $slurm::params::controller_processname,
    hasrestart => $slurm::params::hasrestart,
    hasstatus  => $slurm::params::hasstatus,
    require    => Class['::slurm::config'],
  }
}
