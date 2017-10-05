################################################################################
# Time-stamp: <Thu 2017-10-05 17:58 svarrette>
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
  $required_pkgs = concat($slurm::params::pre_requisite_packages, $slurm::params::extra_packages, $slurm::params::munge_extra_packages)
  $required_pkgs.each |String $pkg| {
    # Safeguard to avoid incompatibility with other puppet modules
    if (!defined(Package[$pkg])) {
      package { $pkg:
        ensure  => 'present',
      }
    }
  }

  # Prepare the user and group
  group { 'slurm':
    ensure => $slurm::ensure,
    name   => $slurm::params::group,
    gid    => $slurm::gid,
  }
  user { 'slurm':
    ensure     => $slurm::ensure,
    name       => $slurm::params::username,
    uid        => $slurm::uid,
    gid        => $slurm::gid,
    comment    => $slurm::params::comment,
    home       => $slurm::params::home,
    managehome => true,
    system     => true,
    shell      => $slurm::params::shell,
  }

  # Order
  if ($slurm::ensure == 'present') {
    Group['slurm'] -> User['slurm']
  }
  else {
    User['slurm'] -> Group['slurm']
  }

  if ($slurm::manage_pam and $slurm::use_pam and ($slurm::with_slurmd or defined(Class['slurm::slurmd'])) {
    include ::slurm::pam
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
    if $slurm::ensure == 'absent' and $slurm::do_package_install {
      Slurm::Install::Packages[$slurm::version] -> Class['slurm::munge']
    }
  }

  if $slurm::with_slurmdbd {
    include ::slurm::slurmdbd
  }
  if $slurm::with_slurmctld {
    include ::slurm::slurmctld
  }
  if $slurm::with_slurmd {
    include ::slurm::slurmd
  }
}

#}
