################################################################################
# Time-stamp: <Tue 2022-07-05 15:22 svarrette>
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

  Class['slurm::common'] -> Class['slurm::install']

  # [Eventually] download and build slurm sources
  if $slurm::do_build {
    # Download the Slurm sources
    slurm::download { $slurm::version :
      ensure        => $slurm::ensure,
      target        => $slurm::srcdir,
      checksum      => $slurm::src_checksum,
      checksum_type => $slurm::src_checksum_type,
    }

    # Now build them
    slurm::build { $slurm::version :
      ensure            => $slurm::ensure,
      srcdir            => $slurm::srcdir,
      dir               => $slurm::builddir,
      with              => $slurm::build_with,
      without           => $slurm::build_without,
      pmix_install_path => $slurm::pmix_install_path,
      require           => Slurm::Download[$slurm::version],
    }
  }

  # [Eventually] Install the built packages/RPMs
  if $slurm::do_package_install {
    slurm::install::packages { $slurm::version :
      ensure    => $slurm::ensure,
      pkgdir    => $slurm::builddir,
      slurmd    => ($slurm::with_slurmd    or defined(Class['::slurm::slurmd'])),
      slurmctld => ($slurm::with_slurmctld or defined(Class['::slurm::slurmctld'])),
      slurmdbd  => ($slurm::with_slurmdbd  or defined(Class['::slurm::slurmdbd'])),
      wrappers  => $slurm::wrappers,
      require   => Slurm::Build[$slurm::version],
    }
  }
}
