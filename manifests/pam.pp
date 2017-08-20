################################################################################
# Time-stamp: <Sun 2017-08-20 17:51 svarrette>
#
# File::      <tt>pam.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Class: slurm::pam
#
# Setup Pluggable Authentication Modules (PAM) (i.e. the module 'pam_slurm') for slurmd
# See https://slurm.schedmd.com/faq.html#pam

class slurm::pam(
  $ensure  = $slurm::ensure,
  $content = template('slurm/pam_slurm.erb'),
  $lines   = undef,
)
{
  validate_re($ensure, ['^present$', '^absent$'] )

  # We assume the RPM 'slurm-pam_slurm' has been already installed

  # TODO: Enable SLURM's use of PAM by setting UsePAM=1 in slurm.conf.
  # Establish a PAM configuration file for slurm
  pam::service { "${slurm::params::pam_servicename}":
    ensure  => "ensure",
    content => $content,
    line    => $lines
  }

}
