################################################################################
# Time-stamp: <Wed 2017-08-23 22:52 svarrette>
#
# File::      <tt>install.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Defines: slurm::install
#
# This definition takes care of installing the Slurm packages, typically built
#  from slurm::build.
# Just like slurm::{download,build}, this definition expects to get as resource
#  name the SLURM version to install
#
# @param ensure       [String]  Default: 'present'
#          Ensure the presence (or absence) of building
# @param pkgdir     [String] Default: '/root/rpmbuild' on redhat systems
#          Top directory of the sources builds (i.e. RPMs, debs...)
#          For instance, built RPMs will be placed under
#          <dir>/RPMS/${::architecture}

# @example install version 17.06.7 (latest at the time of writing)  of SLURMd
#
#     slurm::install { '17.02.7':
  #     ensure => 'present',
  #     pkgdir => "/root/rpmbuild/RPMs/${::architecture}",
  #     slurmd => true
  #   }
#
#
define slurm::install(
  String  $ensure           = $slurm::params::ensure,
  String  $pkgdir           = $slurm::params::builddir,
  Boolean $slurmd           = $slurm::params::with_slurmd,
  Boolean $slurmctld        = $slurm::params::with_slurmctld,
  Boolean $slurmdbd         = $slurm::params::with_slurmdbd,
  Optional[Array] $wrappers = [],
  Optional[Array] $packages = []
)
{
  include ::slurm::params
  validate_legacy('String',  'validate_re',   $ensure, ['^present', '^absent'])
  validate_legacy('String',  'validate_re',   $name,   [ '\d+[\.-]?' ])

  # $name is provided at define invocation
  $version = $name

  if !($slurmd or $slurmctld or $slurmdbd or !empty($packages)) {
    fail("Module ${module_name} expects a non-empty list of [built] packages to install OR specification of which daemon to install (i.e slurm{d,ctld,dbd})")
  }

  # notice("slurmd    = ${slurmd}")
  # notice("slurmctld = ${slurmctld}")
  # notice("slurmdbd  = ${slurmdbd}")

  # Let's build the [default] package list
  $default_packages = $::osfamily ? {
    'Redhat' => ($slurmdbd ? {
      true    => (empty($wrappers) ? {
        true    => concat($slurm::params::common_rpms_basename, $slurm::params::slurmdbd_rpms_basename),
        default => concat($slurm::params::common_rpms_basename, $slurm::params::slurmdbd_rpms_basename, $wrappers)
        }),
      default => (empty($wrappers) ? {
        true    => $slurm::params::common_rpms_basename,
        default => concat($slurm::params::common_rpms_basename, $wrappers)
        })
      }),
    default  => []
  }
  # Full list, including the version numbers
  $pkgs = empty($packages) ? {
    true    => suffix($default_packages, "-${version}"),
    default => suffix($pkgs, "-${version}")
  }
  #notice($pkgs)

  case $::osfamily {
    'Redhat': {
      include ::epel
      include ::yum

      $rpms         = suffix($pkgs, '*.rpm')
      case $ensure {
        'absent': {
          $execname = "yum-remove-slurm*${version}*.rpm"
          $cmd ="yum -y remove slurm*-${version}*"
          $check_onlyif = "test -n \"$(rpm -qa | grep slurm*${version})\""
          $check_unless = "test -z \"$(rpm -qa | grep slurm*${version})\""
        }
        default: {
          $execname  = "yum-localinstall-slurm*${version}*.rpm"
          $cmd          = "yum -y --nogpgcheck localinstall ${join($rpms, ' ')}"
          $check_onlyif = "test -n \"$(ls ${rpms[0]} 2>/dev/null)\""
          $check_unless = prefix($pkgs, 'yum list installed | grep ')
        }
      }
    }
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }

  notice($cmd)
  exec { $execname:
    path    => '/sbin:/usr/bin:/usr/sbin:/bin',
    command => $cmd,
    cwd     => $pkgdir,
    onlyif  => $check_onlyif,
    unless  => $check_unless,
    user    => 'root',
  }

}
