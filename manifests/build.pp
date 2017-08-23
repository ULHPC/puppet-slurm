################################################################################
# Time-stamp: <Wed 2017-08-23 16:05 svarrette>
#
# File::      <tt>build.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Defines: slurm::build
#
# This definition takes care of building Slurm sources into RPMs using 'rpmbuild'.
# This assumes the sources have been downloaded using slurm::download
#
# @param ensure       [String]  Default: 'present'
#          Ensure the presence (or absence) of building
# @param version [String] Default: '17.02.7' (see params.pp)
#          Which version of Slurm to grab and build
# @param srcdir  [String] Default: '/usr/local/src'
#          Where the [downloaded] Slurm sources are located
# @param dir     [String] Default: '/root/rpmbuild' on redhat systems
#          Top directory of the sources builds (i.e. RPMs, debs...)
#          For instance, built RPMs will be placed under
#          <dir>/RPMS/${::architecture}
# @param with    [Array] Default: [ 'lua', ... ] -- see slurm::params
#          see https://github.com/SchedMD/slurm/blob/master/slurm.spec
#          List of --with build options to pass to rpmbuild
# @param without [Array] Default: [] -- see slurm::params
#          see https://github.com/SchedMD/slurm/blob/master/slurm.spec
#          List of --without build options to pass to rpmbuild
#
define slurm::build(
  String  $ensure       = $slurm::params::ensure,
  String  $srcdir       = $slurm::params::srcdir,
  String  $dir          = $slurm::params::builddir,
  Array   $with         = $slurm::params::build_with,
  Array   $without      = $slurm::params::build_without,
)
{
  include ::slurm::params
  validate_legacy('String',  'validate_re',   $ensure, ['^present', '^absent'])
  validate_legacy('String',  'validate_re',   $name,   [ '\d+[\.-]?' ])

  # $name is provided at define invocation
  $version = $name

  # Path to the SLURM sources
  $src = "${srcdir}/slurm-${version}.tar.bz2"

  # Prepare the [RPM] build option
  $with_options = empty($slurm::build::with) ? {
    true    =>  '',
    default => join(prefix($slurm::build::with, '--with '), ' ')
  }
  $without_options = empty($slurm::build::without) ? {
    true    =>  '',
    default => join(prefix($slurm::build::without, '--without '), ' ')
  }
  $buildname = "rpmbuild-slurm-${version}"  # Label for the exec
  $pkgs = concat($slurm::params::pre_requisite_packages, $slurm::params::extra_packages)

  case $::osfamily {
    'Redhat': {
      include ::epel
      include ::yum

      yum::group { $slurm::params::groupinstall:
        ensure  => 'present',
        timeout => 600,
      }
      # Resource default statements
      Package {
        require => Yum::Group[$slurm::params::groupinstall],
        before  => Exec[$buildname]
      }
      $rpmdir = "${dir}/RPMS/${::architecture}"
      $output = "${rpmdir}/slurm-${version}*.rpm"
      # the below command should typically produce the following RPMs
      # slurm[-suffix]-<version>-1.el7.centos.x86_64.rpm
      $cmd    = "rpmbuild -ta ${with_options} ${without_options} --define \"_topdir ${dir}\" ${src}"
    }
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }
  $pkgs.each |String $pkg| {
    # Safeguard to avoid incompatibility with other puppet modules
    if (!defined(Package[$pkg])) {
      package { $pkg:
        ensure  => 'present',
      }
    }
  }
  exec { $buildname:
    path    => '/sbin:/usr/bin:/usr/sbin:/bin',
    command => $cmd,
    cwd     => '/root',
    user    => 'root',
    unless  => "test -n \"$(ls ${output} 2>/dev/null)\"",
  }

}
