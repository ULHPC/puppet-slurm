################################################################################
# Time-stamp: <Tue 2017-08-22 00:17 svarrette>
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

  ######## DEFAULTS FOR VARIABLES USERS CAN SET ##########################
  # (Here are set the defaults, provide your custom variables externally)
  # (The default used is in the line with '')
  ###########################################

  # ensure the presence (or absence) of slurm
  $ensure = 'present'

  # Authentication method for communications between Slurm components.
  $auth_type = 'munge'

  #### MODULE INTERNAL VARIABLES  #########
  # (Modify to adapt to unsupported OSes)
  #########################################
  $pre_requisite_packages = $::operatingsystem ? {
    #/(?i-mx:ubuntu|debian)/        => [],
    /(?i-mx:centos|fedora|redhat)/ => [
      # epel-release vim screen htop wget mailx rng-tools rpm-build gcc gcc-c++ readline-devel openssl openssl-devel pam-devel numactl numactl-devel hwloc hwloc-devel lua lua-devel readline-devel rrdtool-devel ncurses-devel man2html libibmad libibumad perl-devel perl-CPAN hdf5-devel.x86_64 lz4-devel freeipmi-devel hwloc-devel hwloc-plugins rrdtool-devel
    ],
    default => []
  }

  #####################
  ### SLURM Daemons ###
  #####################
  # Make sure the clocks, users and groups (UIDs and GIDs) are synchronized
  # across the cluster.
  # Slurm user / group identifiers
  $uid = 991
  $gid = $uid

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
  $munge_home       = '/var/lib/munge'
  $munge_comment    = "MUNGE Uid 'N' Gid Emporium"
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
