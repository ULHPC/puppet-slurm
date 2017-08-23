# File::      <tt>common/redhat.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Class: slurm::common::redhat
#
# Specialization class for Redhat systems
class slurm::common::redhat inherits slurm::common {

  # Install the built RPMs from slurm::build[::redhat]
  $rpmdir = "${slurm::builddir}/RPMS/${::architecture}"

  # Build the appropriate list of RPMs to install depending on the daemon to install
  $basenames = $slurm::with_slurmdbd ? {
    true    => concat($slurm::params::common_rpms_basename, $slurm::params::slurmdbd_rpms_basename, $slurm::wrappers),
    default => concat($slurm::params::common_rpms_basename, $slurm::wrappers)
  }
  $pkgs = suffix($basenames, "-${slurm::version}")
  $rpms = suffix($pkgs, '*.rpm')
  $cmd  = "yum -y localinstall ${join($rpms, ' ')}"

  # Install them
  exec { "yum-localinstall-slurm*${slurm::version}*.rpm":
    path    => '/sbin:/usr/bin:/usr/sbin:/bin',
    command => $cmd,
    cwd     => $rpmdir,
    onlyif  => "test -n \"$(ls ${rpms[0]} 2>/dev/null)\"",
    unless  => prefix($pkgs, 'yum list installed | grep '),
    user    => 'root',
    require => Slurm::Build[$slurm::version]
  }


}
