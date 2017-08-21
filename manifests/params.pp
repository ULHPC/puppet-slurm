################################################################################
# Time-stamp: <Mon 2017-08-21 14:25 svarrette>
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




  ### Pluggable Authentication Modules (PAM) ###
  $use_pam = true
  # Default content of /etc/pam.d/slurm
  $pam_content = template('slurm/pam_slurm.erb')
  # Source file for /etc/security/limits.d/slurm.conf
  $pam_limits_source = 'puppet:///modules/slurm/limits.memlock'



  # The Protocol used. Used by monitor and firewall class. Default is 'tcp'
  $protocol = 'tcp'

  # The port number. Used by monitor and firewall class. The default is 22.
  $port = 22

  # example of an array/hash variable
  $array_variable = []
  $hash_variable  = {}

  # undef variable
  $undefvar = undef

  #### MODULE INTERNAL VARIABLES  #########
  # (Modify to adapt to unsupported OSes)
  #########################################

  # Pluggable Authentication Modules (PAM) parameters
  $pam_servicename = 'slurm'


  # slurm packages
  $packagename = $::operatingsystem ? {
    default => 'slurm',
  }
  # $extra_packages = $::operatingsystem ? {
    #     /(?i-mx:ubuntu|debian)/        => [],
    #     /(?i-mx:centos|fedora|redhat)/ => [],
    #     default => []
    # }

  # Log directory
  $logdir = $::operatingsystem ? {
    default => '/var/log/slurm'
  }
  $logdir_mode = $::operatingsystem ? {
    default => '750',
  }
  $logdir_owner = $::operatingsystem ? {
    default => 'root',
  }
  $logdir_group = $::operatingsystem ? {
    default => 'adm',
  }

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

  # slurm associated services
  $servicename = $::operatingsystem ? {
    /(?i-mx:ubuntu|debian)/ => 'slurm',
    default                 => 'slurm'
  }
  # used for pattern in a service ressource
  $processname = $::operatingsystem ? {
    /(?i-mx:ubuntu|debian)/ => 'slurm',
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

  $configfile = $::operatingsystem ? {
    default => '/etc/slurm.conf',
  }
  $configfile_init = $::operatingsystem ? {
    /(?i-mx:ubuntu|debian)/ => '/etc/default/slurm',
    default                 => '/etc/sysconfig/slurm'
  }
  $configfile_mode = $::operatingsystem ? {
    default => '0600',
  }
  $configfile_owner = $::operatingsystem ? {
    default => 'root',
  }
  $configfile_group = $::operatingsystem ? {
    default => 'root',
  }


}
