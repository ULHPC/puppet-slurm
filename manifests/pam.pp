################################################################################
# Time-stamp: <Fri 2017-09-01 11:14 svarrette>
#
# File::      <tt>pam.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Class: slurm::pam
#
# Setup Pluggable Authentication Modules (PAM) (i.e. the module 'pam_slurm') for slurmd,
# i.e. /etc/pam.d/slurm and
# See https://slurm.schedmd.com/faq.html#pam
#
# == Parameters
#
# @param ensure  [String]  Default: 'present'
#        Ensure the presence (or absence) of sysctl
# @param allowed_users [Array]  Default: []
#        Manage login access (see PAM_ACCESS(8)) in addition to 'root'
# @param content [String] Default: see 'templates/pam_slurm.erb'
#        Content of /etc/pam.d/slurm
# @param limits_source [String] Default: 'puppet:///modules/slurm/limits.memlock'
#        Source file for /etc/security/limits.d/slurm.conf
# @param use_pam_slurm_adopt [Boolean] Default: false
#        Whether or not use the pam_slurm_adopt  module (to Adopt incoming
#        connections into jobs) -- see
#        https://github.com/SchedMD/slurm/tree/master/contribs/pam_slurm_adopt
#
# /!\ We assume the RPM 'slurm-pam_slurm' has been already installed
#
class slurm::pam(
  String  $ensure              = $slurm::params::ensure,
  Array   $allowed_users       = $slurm::params::pam_allowed_users,
  String  $content             = $slurm::params::pam_content,
  $limits_source               = $slurm::params::limits_source,
  Boolean $use_pam_slurm_adopt = $slurm::params::use_pam_slurm_adopt
)
inherits slurm::params
{
  validate_legacy('String', 'validate_re', $ensure, ['^present', '^absent'])
  validate_legacy('String', 'validate_string', $content)
  #validate_legacy('String', 'validate_string', $limits_source)

  # PAM access
  # Detect vagrant environment to include 'vagrant' in the list of allowed host otherwise
  # the application of this class will prevent the vagrant user to work as expected
  # Trick is to detect ::is_virtual facter + the presence of the /vagrant directory
  # See custom fact 'lib/facter/is_vagrant.rb'
  $default_allowed_users = $::is_vagrant ? {
    true    => [ 'root', 'vagrant'],
    default => [ 'root' ],
  }
  $__allowed_users = empty($allowed_users) ? {
    true    => $default_allowed_users,
    default => concat( $allowed_users, $default_allowed_users),
  }
  #notice($__allowed_users)
  if (! defined('pam')) {
    class { '::pam':
      allowed_users => $__allowed_users,
    }
    # the above class will lead to sssd errors on Redhat systems
    # you might want to enforce the installation of the sssd package in this case
    if $::osfamily == 'RedHat' and !defined(Package['sssd']) {
      package { 'sssd':
        ensure => 'present'
      }
    }
  }
  # Establish a PAM configuration file for slurm /etc/pam.d/slurm
  pam::service { $slurm::params::pam_servicename:
    ensure  => $ensure,
    content => $content,
  }

  if ($use_pam_slurm_adopt) {
    # TODO:
      notice('use pam_slurm_adopt')
  }

  # PAM limits
  if ($limits_source != undef) {
    include ::pam::limits
    # Update PAM MEMLOCK limits (required for MPI)
    pam::limits::fragment { $slurm::params::pam_servicename:
      ensure => $ensure,
      source => $limits_source,
    }
  }

}
