################################################################################
# Time-stamp: <Thu 2017-08-24 16:07 svarrette>
#
# File::      <tt>config/topology.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# == Class: slurm::config::topology
#
# This PRIVATE class handles the Slurm configuration file for defining the network
# topology  i.e. 'topology.conf'
#
# More details: see <https://slurm.schedmd.com/topology.conf.html>
#
class slurm::config::topology inherits slurm::config {
  $content = $slurm::topology_content
  $source  = $slurm::topology_source
  $target  = $slurm::topology_target
  $tree    = $slurm::topology_tree

  if (($content == undef) and ($source == undef) and ($target == undef) and empty($tree)) {
    fail("Module ${module_name} require content specification for '${path}' using either content,source,target,tree")
  }

  # determine the file content
  if empty($tree) {
    $topology_content = $content
  }
  else {
    if ($content != undef) or ($source != undef) {
      fail("${Module_name} cannot have 'content' and/or 'source' attribute(s) when 'tree' is specified")
    }
    $topology_content = template('slurm/topology.conf.erb')
  }
  $ensure = $target ? {
    undef   => $slurm::ensure,
    default => 'link',
  }

  if  $slurm::topology == 'tree' {
    file { 'topology.conf':
      ensure  => $ensure,
      path    => "${slurm::configdir}/topology.conf",
      owner   => $slurm::username,
      group   => $slurm::group,
      mode    => $slurm::params::configfile_mode,
      content => $topology_content,
      source  => $source,
      target  => $target,
    }
  }



}
