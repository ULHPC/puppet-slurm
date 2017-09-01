################################################################################
# Time-stamp: <Fri 2017-09-01 11:20 svarrette>
#
# File::      <tt>install/packages.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Defines: slurm::install::packages
#
# This definition takes care of installing the Slurm packages, typically built
# from slurm::build, for a given version passed as resource name.
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
define slurm::install::packages(
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
  if  $::osfamily == 'RedHat' {
    $common_rpms   = $slurm::params::common_rpms_basename
    $slurmdbd_rpms = $slurm::params::slurmdbd_rpms_basename

    $default_packages = ($slurmdbd ? {
      true    => (($slurmctld or $slurmd) ? {
        true    => (empty($wrappers) ? {
          true    => concat($common_rpms, $slurmdbd_rpms, $wrappers), # slurmdbd + (slurmctld or slurmd) + wrappers
          default => concat($common_rpms, $slurmdbd_rpms),            # slurmdbd + (slurmctld or slurmd)
          }),
        default => (empty($wrappers) ? {
          true    => concat($slurmdbd_rpms, $wrappers), # slurmdbd + wrappers
          default => $common_rpms,                      # slurmdbd
          }),
        }),
      default => (($slurmctld or $slurmd) ? {
        true    => (empty($wrappers) ? {
          true    => concat($common_rpms, $wrappers), # (slurmd or slurmctld) + wrappers
          default => $common_rpms,                    # (slurmd or slurmctld)
          }),
        default => [],   # None of the daemons are requested
        }),
      })
  }
  else {
    $default_packages = []
  }
  # Real Full list
  $pkglist = empty($packages) ? {
    true    => $default_packages,
    default => $pkgs
  }
  #notice($pkglist)
  # ... including the version numbers
  $pkgs = suffix($pkglist, "-${version}")

  case $::osfamily {
    'Redhat': {
      include ::epel
      include ::yum
      $rpms   = suffix($pkgs, '*.rpm')
      $cwddir = ($pkgdir == $slurm::params::builddir) ? {
        true    => "${pkgdir}/RPMS/${::architecture}",
        default => $pkgdir,
      }
      case $ensure {
        'absent': {
          #$execname = "yum-remove-slurm*${version}*.rpm"
          $cmd ="yum -y remove slurm*-${version}*"
          $check_onlyif = "test -n \"$(rpm -qa | grep -E 'slurm.*${version}')\""
          $check_unless = "test -z \"$(rpm -qa | grep -E 'slurm.*${version}')\""
        }
        default: {
          $pkglist.each |String $pkg| {
            if $pkg != 'slurm' {
              Package[$pkg] {
                require => Package['slurm']
              }
            }
            Package[$pkg] {
              provider        => 'rpm',
              install_options => [ '--nodeps' ],
              source          => "${cwddir}/${pkg}-${version}*.rpm",
            }
          }
        }
      }
    }
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }

  # Let's go (independently of the distribution)
  if $ensure == 'present' {
    $pkglist.each |String $pkg| {
      package { $pkg:
        ensure  => $ensure,
      }
    }
  }
  else {
    notice($cmd)
    exec { "uninstall-slurm*${version}*":
      path    => '/sbin:/usr/bin:/usr/sbin:/bin',
      command => $cmd,
      cwd     => $cwddir,
      onlyif  => $check_onlyif,
      unless  => $check_unless,
      user    => 'root',
    }
  }

  # case $ensure {
    #   'absent': {
      #     $execname = "yum-remove-slurm*${version}*.rpm"
      #     $cmd ="yum -y remove slurm*-${version}*"
      #     $check_onlyif = "test -n \"$(rpm -qa | grep slurm*${version})\""
      #     $check_unless = "test -z \"$(rpm -qa | grep slurm*${version})\""
      #   }
    #   default: {
      #     $execname  = "yum-localinstall-slurm*${version}*.rpm"
      #     $cmd          = "yum -y --nogpgcheck localinstall ${join($rpms, ' ')}"
      #     $check_onlyif = "test -n \"$(ls ${cwddir}/${rpms[0]} 2>/dev/null)\""
      #     $check_unless = suffix(prefix($pkglist, "yum list installed | grep ${version} |& grep -E '^"), ".${::architecture}' > /dev/null")
      #   }
    # }
  # Ensure individual RPMs are really installed
  # package { $pkgs:
    #   ensure => $ensure,
    #   provider => 'rpm',
    #   source =>
    # }
  # notice($cmd)
  # notice($check_onlyif)
  # notice($check_unless)
  # exec { $execname:
    #   path    => '/sbin:/usr/bin:/usr/sbin:/bin',
    #   command => $cmd,
    #   cwd     => $cwddir,
    #   onlyif  => $check_onlyif,
    #   unless  => $check_unless,
    #   user    => 'root',
    # }

}
