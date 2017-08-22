################################################################################
# Time-stamp: <Tue 2017-08-22 17:24 svarrette>
#
# File::      <tt>params.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# == Class: slurm::params
#
# In this class are defined as default variables values that are used in all
# other slurm classes and definitions.
# This class should be included, where necessary, and eventually be enhanced
# with support for more Operating Systems.
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# [Remember: No empty lines between comments and class definition]
#
class slurm::params {

  #### MODULE INTERNAL VARIABLES  #########
  # (Modify to adapt to unsupported OSes)
  #########################################
  $pre_requisite_packages = $::osfamily ? {
    'Redhat' => [
      'hwloc', 'hwloc-devel', 'hwloc-plugins', 'numactl', 'numactl-devel',
      'lua', 'lua-devel',
      'mysql-devel',
      'openssl', 'openssl-devel',
      'pam-devel',
      'perl-devel', 'perl-CPAN',
      'readline', 'readline-devel',
    ],
    default => []
  }
  # Probably out of scope here, but useful
  $extra_packages = $::osfamily ? {
    'Redhat' => [
      'libibmad', 'rrdtool-devel',
    ],
    default  => []
  }

  #   #/(?i-mx:ubuntu|debian)/        => [],
  #   /(?i-mx:centos|fedora|redhat)/ => [
  #     # epel-release vim screen htop wget mailx rng-tools rpm-build gcc gcc-c++ readline-devel openssl openssl-devel pam-devel numactl numactl-devel hwloc hwloc-devel lua lua-devel readline-devel rrdtool-devel ncurses-devel man2html libibmad libibumad perl-devel perl-CPAN hdf5-devel.x86_64 lz4-devel freeipmi-devel hwloc-devel hwloc-plugins rrdtool-devel
  #   ],
  #   default => []
  # }
  #########################################
  ### SLURM Configuration (slurm.conf)  ###
  #########################################
  # See https://slurm.schedmd.com/slurm.conf.html
  #
  # Authentication method for communications between Slurm components.
  $auth_type = 'munge'

  #####################
  ### SLURM Daemons ###
  #####################
  # ensure the presence (or absence) of slurm
  $ensure = 'present'

  # Make sure the clocks, users and groups (UIDs and GIDs) are synchronized
  # across the cluster.
  # Slurm user / group identifiers
  $username = 'slurm'
  $uid      = 991
  $group    = $username
  $gid      = $uid
  $home     = "/var/lib/${username}"
  $comment  = 'SLURM workload manager'
  $shell    = '/bin/bash'

  # Slurmd associated services
  $servicename = $::operatingsystem ? {
    default                 => 'slurm'
  }
  # used for pattern in a service ressource
  $processname = $::operatingsystem ? {
    default                 => 'slurm'
  }
  $hasstatus = $::operatingsystem ? {
    /(?i-mx:ubuntu|debian)/        => false,
    /(?i-mx:centos|fedora|redhat)/ => true,
    default => true,
  }
  $hasrestart = $::operatingsystem ? {
    default => true,
  }

  ##########################################
  ### SLURM Sources and Building Process ###
  ##########################################
  # Which group install is required to build the Slurm sources -- see slurm::build[::redhat]
  # Makes only sense on yum-based systems
  $groupinstall = $::osfamily ? {
    'Redhat' => 'Development tools',
    default  => undef
  }
  # Which version of Slurm to grab and build
  $version = '17.02.7'

  ### SLURM Sources
  # Checksum for the slurm source archive (empty means no check will be done)
  $src_checksum = '64009c1ed120b9ce5d79424dca743a06'
  # From where the Slurm sources can be downloaded
  $download_baseurl    = 'https://www.schedmd.com/downloads'
  $download_latestdir  = 'latest'
  $download_archivedir = 'archive'
  # Whether the remote source archive has been already archived (this
  # unfortunately changes the URL to download from)
$src_archived        = false
# Where to place the sources
$srcdir = $::operatingsystem ? {
  default => '/usr/local/src'
}
### Slurm Build
# Where to place the builds of the sources (i.e. RPMs, debs...)
$builddir = $::osfamily ? {
  'Redhat' => "/root/rpmbuild/RPMS/${::architecture}", # RPMs Build directory
  default  => "/tmp/slurmbuild/${::architecture}",
}
# Build options -- see https://github.com/SchedMD/slurm/blob/master/slurm.spec
$build_with = [
  #'auth_none',    # build auth-none RPM
  #'blcr',         # require blcr support
  #'bluegene',     # build bluegene RPM
  #'cray',         # build for a Cray system without ALPS
  #'cray_alps',    # build for a Cray system with ALPS
  #'cray_network', # build for a non-Cray system with a Cray network
  'lua',           # build Slurm lua bindings (proctrack only for now)
  'mysql',         # require mysql/mariadb support
  'openssl',       # require openssl RPM to be installed
  #'percs',        # build percs RPM IBM
  #'sgijob',       # build proctrack-sgi-job RPM
]
$build_without = [
  #'debug',        # don't compile with debugging symbols
  #'munge',        # don't build auth-munge RPM
  #'netloc',       # require netloc support
  #'pam',          # don't require pam-devel RPM to be installed
  #'readline',     # don't require readline-devel RPM to be installed
]

####################################
### MUNGE authentication service ###
####################################
# see https://github.com/dun/munge
# We assume it will be used for shared key authentication, and the shared key
# can be provided to puppet via a URI.
# Munge user/group identifiers, and attributes for the munge user
$munge_username   = 'munge'
$munge_uid        = 992
$munge_group      = $munge_username
$munge_gid        = $munge_uid
$munge_home       = "/var/lib/${munge_username}"
$munge_comment    = "MUNGE Uid 'N' Gid Emporium"
$munge_shell      = '/sbin/nologin'
# Should the key be created if absent ?
$munge_create_key = true #false
$munge_key        = '/etc/munge/munge.key'
# Set the content of the DAEMON_ARGS variable
$munge_daemon_args = []
# Packages to install
$munge_package = $::operatingsystem ? {
  default => 'munge'
}
$munge_extra_packages = $::operatingsystem ? {
  /(?i-mx:ubuntu|debian)/        => [ 'libmunge-dev' ],
  /(?i-mx:centos|fedora|redhat)/ => [ 'munge-libs', 'munge-devel' ],
  default => [ ]
}
$munge_configdir = $::operatingsystem ? {
  default => '/etc/munge',
}
$munge_logdir = $::operatingsystem ? {
  default => '/var/log/munge',
}
$munge_piddir = $::operatingsystem ? {
  default => '/var/run/munge',
}
$munge_sysconfigdir = $::operatingsystem ? {
  /(?i-mx:ubuntu|debian)/ => '/etc/default/munge',
  default                 => '/etc/sysconfig/munge'
}
$munge_servicename = $::operatingsystem ? {
  default => 'munge'
}
$munge_processname = $::operatingsystem ? {
  default => 'munge'
}

##############################################
### Pluggable Authentication Modules (PAM) ###
##############################################
$use_pam = true
$pam_servicename = 'slurm'
# Default content of /etc/pam.d/slurm
$pam_content = template('slurm/pam_slurm.erb')
# Source file for /etc/security/limits.d/slurm.conf
$pam_limits_source   = 'puppet:///modules/slurm/limits.memlock'
# Whether or not use the pam_slurm_adopt  module (to Adopt incoming
# connections into jobs) -- see
# https://github.com/SchedMD/slurm/tree/master/contribs/pam_slurm_adopt
$use_pam_slurm_adopt = false

# # slurm packages
# $packagename = $::operatingsystem ? {
  #   default => 'slurm',
  # }
# $extra_packages = $::operatingsystem ? {
  #     /(?i-mx:ubuntu|debian)/        => [],
  #     /(?i-mx:centos|fedora|redhat)/ => [],
  #     default => []
  # }

### Log directory
# $logdir = $::operatingsystem ? {
  #   default => '/var/log/slurm'
  # }
# $logdir_mode = $::operatingsystem ? {
  #   default => '750',
  # }
# $logdir_owner = $::operatingsystem ? {
  #   default => 'root',
  # }
# $logdir_group = $::operatingsystem ? {
  #   default => 'adm',
  # }

# PID for daemons
# $piddir = $::operatingsystem ? {
  #     default => "/var/run/slurm",
  # }
# $piddir_mode = $::operatingsystem ? {
  #     default => '750',
  # }
# $piddir_owner = $::operatingsystem ? {
  #     default => 'slurm',
  # }
# $piddir_group = $::operatingsystem ? {
  #     default => 'adm',
  # }
# $pidfile = $::operatingsystem ? {
  #     default => '/var/run/slurm/slurm.pid'
  # }



# Configuration directory & file
# $configdir = $::operatingsystem ? {
  #     default => "/etc/slurm",
  # }
# $configdir_mode = $::operatingsystem ? {
  #     default => '0755',
  # }
# $configdir_owner = $::operatingsystem ? {
  #     default => 'root',
  # }
# $configdir_group = $::operatingsystem ? {
  #     default => 'root',
  # }

# $configfile = $::operatingsystem ? {
  #   default => '/etc/slurm/slurm.conf',
  # }
# $configfile_init = $::operatingsystem ? {
  #   /(?i-mx:ubuntu|debian)/ => '/etc/default/slurm',
  #   default                 => '/etc/sysconfig/slurm'
  # }
# $configfile_mode = $::operatingsystem ? {
  #   default => '0600',
  # }
# $configfile_owner = $::operatingsystem ? {
  #   default => 'root',
  # }
# $configfile_group = $::operatingsystem ? {
  #   default => 'root',
  # }


}
