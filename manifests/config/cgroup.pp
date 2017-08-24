################################################################################
# Time-stamp: <Thu 2017-08-24 16:36 svarrette>
#
# File::      <tt>config/cgroup.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# == Class: slurm::config::cgroup
#
# This PRIVATE class handles the Slurm configuration file for the cgroup support
# i.e. 'cgroup.conf'
#
# More details: see <https://slurm.schedmd.com/cgroup.conf.html>
#
# For general Slurm Cgroups information, see the Cgroups Guide at
# <https://slurm.schedmd.com/cgroups.html>.
class slurm::config::cgroup inherits slurm::config {

  # NOTE: Debian and derivatives (e.g. Ubuntu) usually exclude the memory and
  # memsw (swap) cgroups by default. To include them, add the following
  # parameters to the kernel command line: cgroup_enable=memory swapaccount=1

  $cgroup_content = $slurm::cgroup_content ? {
    undef   => template('slurm/cgroup.conf.erb'),
    default => $slurm::cgroup_content,
  }
  $ensure = $slurm::cgroup_target ? {
    undef   => $slurm::ensure,
    default => 'link',
  }
  # cgroup.conf
  file { $slurm::params::cgroup_configfile:
    ensure  => $ensure,
    path    => "${slurm::configdir}/${slurm::params::cgroup_configfile}",
    owner   => $slurm::username,
    group   => $slurm::group,
    mode    => $slurm::params::configfile_mode,
    content => $cgroup_content,
    source  => $slurm::cgroup_source,
    target  => $slurm::cgroup_target,
  }


  # [eventually] cgroup_allowed_devices_file.conf
  if !empty($slurm::cgroup_alloweddevices) {
    file { $slurm::params::cgroup_alloweddevices_configfile:
      ensure  => $slurm::ensure,
      path    => "${slurm::configdir}/${slurm::params::cgroup_alloweddevices_configfile}",
      owner   => $slurm::username,
      group   => $slurm::group,
      mode    => $slurm::params::configfile_mode,
      content => template('slurm/cgroup_allowed_devices_file.conf.erb')
    }
  }



  # if (($content == undef) and ($source == undef) and ($target == undef) and empty($tree)) {
    #   fail("Module ${module_name} require content specification for '${path}' using either content,source,target,tree")
    # }

  # # determine the file content
  # if empty($tree) {
    #   $topology_content = $content
    # }
  # else {
    #   if ($content != undef) or ($source != undef) {
      #     fail("${Module_name} cannot have 'content' and/or 'source' attribute(s) when 'tree' is specified")
      #   }
    #   $topology_content = template("slurm/topology.conf.erb")
    # }

  # if  $slurm::topology == 'tree' {
    #   file { 'topology.conf':
      #     ensure  => $slurm::ensure,
      #     path    => "${slurm::configdir}/topology.conf",
      #     owner   => $slurm::username,
      #     group   => $slurm::group,
      #     mode    => $slurm::params::configfile_mode,
      #     content => $topology_content,
      #     source  => $source,
      #   }
    # }



}
