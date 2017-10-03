################################################################################
# Time-stamp: <Wed 2017-10-04 00:02 svarrette>
#
# File::      <tt>firewall.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Defines: slurm::firewall
#
# This definition takes care of firewall aspects for SLURM
#
#
define slurm::firewall(
  Enum[
    'present',
    'absent'
  ]       $ensure   = 'present',
  String  $zone     = 'public',
  String  $port     = '',
  String  $seltype  = '',
  String  $protocol = 'tcp',
)
{
  include ::slurm::params

  if ($::osfamily != 'RedHat' or versioncmp($facts['os']['release']['major'], '7') < 0 {
    fail("Module ${module_name} is not supported on ${::operatingsystem}")
  }

  # $name is provided at define invocation
  $port_range = empty($port) {
    true    => $name,
    default => $port,
  }

  if (defined(Class['firewalld'])) {
    ###### CentOS/RHEL 7 with firewalld
    firewalld_port { "slurm-${range}":
      ensure   => $ensure,
      zone     => $zone,
      port     => $port_range,
      protocol => $protocol,
    }
    if (defined(Class['selinux']) and $facts['os']['selinux']['enabled'] and !empty($seltype)) {
      $array_range = split($port_range, '-')
      selinux::port { "slurm-allow-${seltype}-port-${port_range}":
        ensure     => $ensure,
        seltype    => $seltype,
        protocol   => $protocol,
        port_range => [ ($array_range[0]+0), ($array_range[1]+0) ],
      }
    }
  }


  }
