################################################################################
# Time-stamp: <Sun 2019-02-03 15:02 svarrette>
#
# File::      <tt>download.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Defines: slurm::download
#
# This definition takes care of downloading the SLURM sources for a given version
# (passed as name to this resource) and placing them into $target directory.
# You can also invoke this definition with the full archive filename i.e.
# slurm-<version>.tar.bz2.
#
# @param ensure [String]  Default: 'present'
#          Ensure the presence (or absence) of building
# @param target [String] Default: '/usr/local/src'
#          Target directory for the downloaded sources
# @param archived [Boolean] Default: false
#          Whether the sources tar.bz2 has been archived or not.
#          Thus by default, it is assumed that the provided version is the
#          latest version (from https://www.schedmd.com/downloads/latest/).
#          If set to true, the sources will be download from
#             https://www.schedmd.com/downloads/archive/
# @param checksum_type [String] Default: 'md5'
#          archive file checksum type (none|md5|sha1|sha2|sh256|sha384| sha512).
# @param checksum_verify [Boolean] Default: false
#          whether checksum will be verified (true|false).
# @param checksum [String] Default: ''
#           archive file checksum (match checksum_type)
#
# @example Downloading version 17.11.12 of SLURM
#
#     slurm::download { '17.11.12':
#        ensure        => 'present',
#        checksum      => '42f0a5dbe34210283f474328ac6e8d5267dc2386',
#        checksum_type => 'sha1',
#        archived      => true,
#        target        => '/usr/local/src/',
#   }
#
define slurm::download(
  String  $ensure          = $slurm::params::ensure,
  String  $target          = $slurm::params::srcdir,
  Boolean $archived        = $slurm::params::src_archived,
  String  $checksum        = '',
  String  $checksum_type   = $slurm::params::src_checksum_type,
  Boolean $checksum_verify = false,
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

  $real_checksum_type = empty($checksum) ? {
    true    => 'none',
    default => $checksum_type
  }
  # notice("checksum      = ${checksum}")
  # notice("checksum_type = ${real_checksum_type}")

  # Download the sources using puppet-archive module
  archive { $archive:
    ensure          => $ensure,
    path            => $path,
    source          => $url,
    user            => $slurm::params::username,
    group           => $slurm::params::group,
    checksum_type   => $real_checksum_type,
    checksum_verify => ($checksum_verify or ! empty($checksum)),
    checksum        => $checksum,
    cleanup         => false,
    extract         => false,
    creates         => $path,
  }
  if $ensure == 'absent' {
    file {$path:
      ensure  => $ensure,
      require => Archive[$archive],
    }
  }

}
