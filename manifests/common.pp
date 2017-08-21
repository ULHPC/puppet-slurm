################################################################################
# Time-stamp: <Mon 2017-08-21 21:42 svarrette>
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
    }
  }

  if ($slurm::auth_type =~ /munge/) {
    class { '::slurm::munge':
      #ensure        => 'absent' #$slurm::ensure,
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

}
