################################################################################
# Time-stamp: <Fri 2017-09-01 09:15 svarrette>
#
# File::      <tt>common.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Class: slurm::common
#
# Base class to be inherited by the other slurm classes, containing the common code.
#

class slurm::common {

  # Load the variables used in this module. Check the params.pp file
  require ::slurm::params

  # Install preliminary packages
  $required_pkgs = concat($slurm::params::pre_requisite_packages, $slurm::params::extra_packages)
  $required_pkgs.each |String $pkg| {
    # Safeguard to avoid incompatibility with other puppet modules
    if (!defined(Package[$pkg])) {
      package { $pkg:
        ensure  => 'present',
      }
    }
  }

  if ($slurm::manage_pam and $slurm::use_pam and $slurm::with_slurmd) {
    class { '::slurm::pam':
      ensure        => $slurm::ensure,
      content       => $slurm::pam_content,
      limits_source => $slurm::pam_limits_source,
      allowed_users => $slurm::pam_allowed_users,
    }
  }

  if ($slurm::manage_munge and $slurm::authtype =~ /munge/) {
    class { '::slurm::munge':
      ensure       => $slurm::ensure,
      create_key   => $slurm::munge_create_key,
      daemon_args  => $slurm::munge_daemon_args,
      uid          => $slurm::munge_uid,
      gid          => $slurm::munge_gid,
      key_source   => $slurm::munge_key_source,
      key_content  => $slurm::munge_key_content,
      key_filename => $slurm::munge_key_filename,
    }
  }

  if ($slurm::with_slurmd or $slurm::with_slurmctld or $slurm::with_slurmdbd) {
    include ::slurm::install
    include ::slurm::config
    Class['::slurm::install'] -> Class['::slurm::config']

    if $slurm::with_slurmd {
      include ::slurm::slurmd
    }
    if $slurm::with_slurmctld {
      include ::slurm::slurmctld
    }
    if $slurm::with_slurmdbd {
      include ::slurm::slurmdbd
    }
  }

}
