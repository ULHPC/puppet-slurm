################################################################################
# Time-stamp: <Fri 2017-09-01 11:51 svarrette>
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
      slurmd    => ($slurm::with_slurmd    or defined('slurm::slurmd')),
      slurmctld => ($slurm::with_slurmctld or defined('slurm::slurmctld')),
      slurmdbd  => ($slurm::with_slurmdbd  or defined('slurm::slurmdbd')),
      wrappers  => $slurm::wrappers,
      require   => Slurm::Build[$slurm::version],
    }
  }











}
