################################################################################
# Time-stamp: <Wed 2017-08-23 11:12 svarrette>
#
# File::      <tt>build/redhat.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Class: slurm::build::redhat
#
# Specialization class for building Slurm RPMs on Redhat systems
#
class slurm::build::redhat inherits slurm::build {
  # Path to the SLURM sources
  $src = "${slurm::build::srcdir}/slurm-${slurm::build::version}.tar.bz2"

  # Prepare the RPM build option
  $with_options = empty($slurm::build::with) ? {
    true    =>  '',
    default => join(prefix($slurm::build::with, '--with '), ' ')
  }
  $without_options = empty($slurm::build::without) ? {
    true    =>  '',
    default => join(prefix($slurm::build::without, '--without '), ' ')
  }
  $buildname = "rpmbuild-slurm-${slurm::build::version}"

  ### Let's go ###
  include ::epel
  include ::yum

  yum::group { $slurm::params::groupinstall:
    ensure  => 'present',
    timeout => 600,
  }

  concat($slurm::params::pre_requisite_packages, $slurm::params::extra_packages).each |String $pkg| {
    # Safeguard to avoid incompatibility with other puppet modules
    if (!defined(Package[$pkg])) {
      package { $pkg:
        ensure  => 'present',
        require => Yum::Group[$slurm::params::groupinstall],
        before  => Exec[$buildname]
      }
    }
  }
  $rpmdir = "${slurm::build::dir}/RPMS/${::architecture}"
  $rpmbuild_cmd = "rpmbuild -ta ${with_options} ${without_options} --define \"_topdir ${slurm::build::dir}\" ${src}"

  # The build should produce at least the following RPM
  # slurm-<version>-1.el7.centos.x86_64.rpm
  exec { $buildname:
    path    => '/sbin:/usr/bin:/usr/sbin:/bin',
    command => $rpmbuild_cmd,
    cwd     => '/root',
    user    => 'root',
    unless  => "test -n \"$(ls ${rpmdir}/slurm-${slurm::build::version}*.rpm 2>/dev/null)\"",
    require => [
      Yum::Group[$slurm::params::groupinstall]
    ]
  }
}
