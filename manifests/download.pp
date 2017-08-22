################################################################################
# Time-stamp: <Tue 2017-08-22 14:26 svarrette>
#
# File::      <tt>download.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Defines: slurm::download
#
# This class takes care of downloading the SLURM sources for a given version
# (passed as name) and placing them into $target directory
#
# == Parameters
#
# @param ensure       [String]  Default: 'present'
#        Ensure the presence (or absence) of building
#
# @example Downloading version 17.06.7 (latest) version of SLURM
#
#     slurm::download { '17.02.7':
  #     ensure    => 'present',
  #     checksurm => '64009c1ed120b9ce5d79424dca743a06',
  #     target    => '/usr/local/src/',
  #   }
#
# @example Downloading archived version 16.05.10 version of SLURM
#
#     slurm::download { 'slurm-16.05.10.tar.bz2':
  #     ensure   => 'present',
  #     archived => true,
  #     target   => '/usr/local/src/',
  #   }
#
define slurm::download(
  String  $ensure          = $slurm::params::ensure,
  String  $target          = $slurm::params::srcdir,
  String  $user            = $slurm::params::username,
  String  $group           = $slurm::params::group,
  Boolean $archived        = false,
  String  $checksum_type   = 'md5',
  Boolean $checksum_verify = false,
  String  $checksum        = '',
  Boolean $cleanup         = false

)
{
  include ::slurm::params

  validate_legacy('String',  'validate_re',   $ensure, ['^present', '^absent'])
  validate_legacy('String',  'validate_re',   $name,   [ 'slurm-.*\.tar\.bz2', '\d+[\.-]?' ])

  # $name is provided at define invocation
  if $name =~ /slurm-(.*)\.tar\.bz2/ {  # Full archive name provided
    $archive = $name
    $version = $1
  }
  elsif ($name =~ /\d+[\.-]?/ ) {       # only the version was provided
    $version = $name
    $archive = "slurm-${version}.tar.bz2"
  }
  else { fail("Wrong specification for ${module_name}") }
  # URL from where to download the sources
  $url = $archived ? {
    true    => "${slurm::params::download_baseurl}/${slurm::params::download_archivedir}/${archive}",
    default => "${slurm::params::download_baseurl}/${slurm::params::download_latestdir}/${archive}"
  }
  # Absolute path to the downloaded source file
  $path =  "${target}/${archive}"

  # Download the sources using puppet-archive module
  archive { $archive:
    ensure          => $ensure,
    path            => $path,
    source          => $url,
    user            => $user,
    group           => $group,
    checksum_type   => $checksum_type,
    checksum_verify => ($checksum_verify or empty($checksum)),
    checksum        => $checksum,
    cleanup         => $cleanup,
    extract         => false,
    creates         => $path,
  }

}
