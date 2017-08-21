################################################################################
# Time-stamp: <Mon 2017-08-21 14:04 svarrette>
#
# File::      <tt>pam.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Class: slurm::pam
#
# Setup Pluggable Authentication Modules (PAM) (i.e. the module 'pam_slurm') for slurmd,
# i.e. /etc/pam.d/slurm and
# See https://slurm.schedmd.com/faq.html#pam
#
# == Parameters
#
# @param ensure  [String]  Default: 'present'
#        Ensure the presence (or absence) of sysctl
# @param content [String] Default: see 'templates/pam_slurm.erb'
#
#
#
# /!\ We assume the RPM 'slurm-pam_slurm' has been already installed

class slurm::pam(
  String $ensure  = $slurm::params::ensure,
  String $content = template('slurm/pam_slurm.erb'),
  String $limits_source = "puppet:///modules/slurm/limits.memlock"
)
inherits slurm::params
{
  validate_legacy('String', 'validate_re', $ensure, ['^present', '^absent'])

  # TODO: Enable SLURM's use of PAM by setting UsePAM=1 in slurm.conf.

  # Establish a PAM configuration file for slurm
  pam::service { "${slurm::params::pam_servicename}":
    ensure  => $ensure,
    content => $content
  }
  include pam::limits

  # Update PAM MEMLOCK limits (required for MPI)
  pam::limits::fragment { "${slurm::params::pam_servicename}":
    ensure => $ensure,
    source => $limits_source
  }

}
