################################################################################
# Time-stamp: <Fri 2019-02-01 08:51 svarrette>
#
# File::      <tt>config.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# == Class: slurm::config
#
# This PRIVATE class handles the configuration of SLURM daemons
# More details on <https://slurm.schedmd.com/slurm.conf.html#lbAN> and also on
# - https://slurm.schedmd.com/slurm.conf.html
# - https://slurm.schedmd.com/slurmdbd.conf.html
# - https://slurm.schedmd.com/topology.conf.html
# - https://slurm.schedmd.com/cgroup.conf.html
#
class slurm::config {

  include ::slurm
  include ::slurm::params

  # Prepare the directory structure
  $pluginsdir = "${slurm::configdir}/${slurm::params::pluginsdir}"
  $slurmdirs = [
    $slurm::configdir,
    $slurm::params::logdir,
    #$slurm::params::piddir,  # NO support for specialized piddir as per service definitions
    $pluginsdir,
  ]
  if $slurm::ensure == 'present' {
    file { $slurmdirs:
      ensure => 'directory',
      owner  => $slurm::params::username,
      group  => $slurm::params::group,
      mode   => $slurm::params::configdir_mode,
    }
    File[$slurm::configdir] -> File[$pluginsdir]
    if ((!empty($slurm::plugins)) and ($slurm::pluginsdir_target != undef)) {
      $slurm::plugins.each |String $plugin| {
        file { "${pluginsdir}/${plugin}.conf":
          ensure  => 'link',
          target  => "${slurm::pluginsdir_target}/${plugin}.conf",
          owner   => $slurm::params::username,
          group   => $slurm::params::group,
          require => File[$pluginsdir],
        }
      }
    }
  }
  else {
    file { $slurmdirs:
      ensure => $slurm::ensure,
      force  => true,
    }
    File[$pluginsdir] -> File[$slurm::configdir]
  }

  # Now let's deal with slurm.conf
  $slurm_content = $slurm::content ? {
    undef   => $slurm::source ? {
      undef   => $slurm::target ? {
        undef   => template('slurm/slurm.conf.erb'),
        default => $slurm::content,
      },
      default => $slurm::content
    },
    default => $slurm::content,
  }
  $ensure = $slurm::target ? {
    undef   => $slurm::ensure,
    default => 'link',
  }

  # notice(defined(Class['slurm::slurmdbd']))
  # notice(defined(Class['slurm::slurmctld']))
  # notice(defined(Class['slurm::slurmd']))

  if $slurm::with_slurmctld or $slurm::with_slurmd or defined(Class['slurm::slurmctld']) or defined(Class['slurm::slurmd']) or defined(Class['slurm::login']) {

    # Bash completion
    file { '/etc/bash_completion.d/slurm_completion.sh':
      ensure => $slurm::ensure,
      source => 'puppet:///modules/slurm/slurm_completion.sh',
      mode   => '0644',
    }

    # Main slurm.conf
    $filename = "${slurm::configdir}/${slurm::params::configfile}"
    file { $slurm::params::configfile:
      ensure  => $ensure,
      path    => $filename,
      owner   => $slurm::username,
      group   => $slurm::group,
      mode    => $slurm::params::configfile_mode,
      content => $slurm_content,
      source  => $slurm::source,
      target  => $slurm::target,
      tag     => 'slurm::configfile',
    }

    # Now add the other configuration files
    include ::slurm::config::cgroup
    include ::slurm::config::gres
    include ::slurm::config::topology

    # Eventually, add the [default] plugins
    if member($slurm::build_with, 'lua') {
      include ::slurm::plugins::lua
    }

    if $slurm::ensure == 'present' {
      File <| tag == 'slurm::configfile' |> {
        require  +> File[$slurm::configdir],
      }
    }

  }


}
