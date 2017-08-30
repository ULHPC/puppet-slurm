################################################################################
# Time-stamp: <Wed 2017-08-30 15:54 svarrette>
#
# File::      <tt>common.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Class: slurm::common
#
# Base class to be inherited by the other slurm classes, containing the common code.
#

class slurm::common {

  # Load the variables used in this module. Check the params.pp file
  require ::slurm::params

  if $slurm::use_pam {
    class { '::slurm::pam':
      ensure        => $slurm::ensure,
      content       => $slurm::pam_content,
      limits_source => $slurm::pam_limits_source,
      allowed_users => $slurm::pam_allowed_users,
    }
  }

  if ($slurm::authtype =~ /munge/) {
    class { '::slurm::munge':
      ensure       => $slurm::ensure,
      create_key   => $slurm::munge_create_key,
      daemon_args  => $slurm::munge_daemon_args,
      uid          => $slurm::munge_uid,
      gid          => $slurm::munge_gid,
      key_source   => $slurm::munge_key_source,
      key_content  => $slurm::munge_key_content,
      key_filename => $slurm::munge_key_filename,
    }
  }

  include ::slurm::install
  include ::slurm::config

  Class['::slurm::install'] -> Class['::slurm::config']

  if $slurm::with_slurmd {
    include slurm::slurmd
  }
  if $slurm::with_slurmctld {
    include slurm::slurmctld
  }

}



# package { 'slurm':
  #     name    => "${slurm::params::packagename}",
  #     ensure  => "${slurm::ensure}",
  # }
# # package { $slurm::params::extra_packages:
  # #     ensure => 'present'
  # # }

# if $slurm::ensure == 'present' {

  #     # Prepare the log directory
  #     file { "${slurm::params::logdir}":
    #         ensure => 'directory',
    #         owner  => "${slurm::params::logdir_owner}",
    #         group  => "${slurm::params::logdir_group}",
    #         mode   => "${slurm::params::logdir_mode}",
    #         require => Package['slurm'],
    #     }

  #     # Configuration file
  #     # file { "${slurm::params::configdir}":
    #     #     ensure => 'directory',
    #     #     owner  => "${slurm::params::configdir_owner}",
    #     #     group  => "${slurm::params::configdir_group}",
    #     #     mode   => "${slurm::params::configdir_mode}",
    #     #     require => Package['slurm'],
    #     # }
  #     # Regular version using file resource
  #     file { 'slurm.conf':
    #         path    => "${slurm::params::configfile}",
    #         owner   => "${slurm::params::configfile_owner}",
    #         group   => "${slurm::params::configfile_group}",
    #         mode    => "${slurm::params::configfile_mode}",
    #         ensure  => "${slurm::ensure}",
    #         #content => template("slurm/slurmconf.erb"),
    #         #source => "puppet:///modules/slurm/slurm.conf",
    #         #notify  => Service['slurm'],
    #         require => [
      #                     #File["${slurm::params::configdir}"],
      #                     Package['slurm']
      #                     ],
    #     }

  #     # # Concat version -- see https://forge.puppetlabs.com/puppetlabs/concat
  #     # include concat::setup
  #     # concat { "${slurm::params::configfile}":
    #     #     warn    => false,
    #     #     owner   => "${slurm::params::configfile_owner}",
    #     #     group   => "${slurm::params::configfile_group}",
    #     #     mode    => "${slurm::params::configfile_mode}",
    #     #     #notify  => Service['slurm'],
    #     #     require => Package['slurm'],
    #     # }
  #     # # Populate the configuration file
  #     # concat::fragment { "${slurm::params::configfile}_header":
    #     #     target  => "${slurm::params::configfile}",
    #     #     ensure  => "${slurm::ensure}",
    #     #     content => template("slurm/slurm_header.conf.erb"),
    #     #     #source => "puppet:///modules/slurm/slurm_header.conf",
    #     #     order   => '01',
    #     # }
  #     # concat::fragment { "${slurm::params::configfile}_footer":
    #     #     target  => "${slurm::params::configfile}",
    #     #     ensure  => "${slurm::ensure}",
    #     #     content => template("slurm/slurm_footer.conf.erb"),
    #     #     #source => "puppet:///modules/slurm/slurm_footer.conf",
    #     #     order   => '99',
    #     # }

  #     # PID file directory
  #     # file { "${slurm::params::piddir}":
    #     #     ensure  => 'directory',
    #     #     owner   => "${slurm::params::piddir_user}",
    #     #     group   => "${slurm::params::piddir_group}",
    #     #     mode    => "${slurm::params::piddir_mode}",
    #     # }

  #     file { "${slurm::params::configfile_init}":
    #         owner   => "${slurm::params::configfile_owner}",
    #         group   => "${slurm::params::configfile_group}",
    #         mode    => "${slurm::params::configfile_mode}",
    #         ensure  => "${slurm::ensure}",
    #         #content => template("slurm/default/slurm.erb"),
    #         #source => "puppet:///modules/slurm/default/slurm.conf",
    #         notify  =>  Service['slurm'],
    #         require =>  Package['slurm']
    #     }

  #     service { 'slurm':
    #         name       => "${slurm::params::servicename}",
    #         enable     => true,
    #         ensure     => running,
    #         hasrestart => "${slurm::params::hasrestart}",
    #         pattern    => "${slurm::params::processname}",
    #         hasstatus  => "${slurm::params::hasstatus}",
    #         require    => [
      #                        Package['slurm'],
      #                        File["${slurm::params::configfile_init}"]
      #                        ],
    #         subscribe  => File['slurm.conf'],
    #     }
  # }
# else
# {
  #     # Here $slurm::ensure is 'absent'

  # }
