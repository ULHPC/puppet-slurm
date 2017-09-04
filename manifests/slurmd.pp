################################################################################
# Time-stamp: <Mon 2017-09-04 21:24 svarrette>
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
  case $::osfamily {
    'Redhat': { }
    default:  { fail("Module ${module_name} is not supported on ${::operatingsystem}") }
  }

  include ::slurm::install
  include ::slurm::config

  File <| tag == 'slurm::configfile' |> {
    notify  +> Service['slurmd'],
  }

  if $slurm::service_manage == true {
    service { 'slurmd':
      ensure     => ($slurm::ensure == 'present'),
      enable     => ($slurm::ensure == 'present'),
      name       => $slurm::params::servicename,
      pattern    => $slurm::params::processname,
      hasrestart => $slurm::params::hasrestart,
      hasstatus  => $slurm::params::hasstatus,
      require    => Class['::slurm::config'],
    }

    if ($slurm::with_slurmctld or defined(Class['slurm::slurmctld'])) {
      Service['slurmctld'] -> Service['slurmd']
    }
  }
}
