################################################################################
# Time-stamp: <Wed 2017-08-30 15:34 svarrette>
#
# File::      <tt>install.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# == Class: slurm::install
#
# This PRIVATE class handles the installation of SLURM
#
class slurm::install {

  include ::slurm
  include ::slurm::params

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

  # [Eventually] download and build slurm sources
  if $slurm::do_build {
    # Download the Slurm sources
    slurm::download { $slurm::version :
      ensure   => $slurm::ensure,
      target   => $slurm::srcdir,
      archived => $slurm::src_archived,
      checksum => $slurm::src_checksum,
    }

    # Now build them
    slurm::build { $slurm::version :
      ensure  => $slurm::ensure,
      srcdir  => $slurm::srcdir,
      dir     => $slurm::builddir,
      with    => $slurm::build_with,
      without => $slurm::build_without,
      require => Slurm::Download[$slurm::version],
    }
  }

  # [Eventually] Install the built packages/RPMs
  if $slurm::do_package_install {
    slurm::install::packages { $slurm::version :
      ensure    => $slurm::ensure,
      slurmd    => $slurm::with_slurmd,
      slurmctld => $slurm::with_slurmctld,
      slurmdbd  => $slurm::with_slurmdbd,
      wrappers  => $slurm::wrappers,
      require   => Slurm::Build[$slurm::version],
    }
  }









}
