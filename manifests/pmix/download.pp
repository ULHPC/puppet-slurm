################################################################################
# Time-stamp: <Mon 2019-10-07 22:37 svarrette>
#
# File::      <tt>pmix/download.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2019 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# = Defines: slurm::pmix::download
#
# This definition takes care of downloading PMIx sources sources for a given version
# (passed as name to this resource) and placing them into $target directory
# according to the guidelines provided on
# https://pmix.org/support/how-to/slurm-support/#building
#
# Latest PMIx releases: https://github.com/openpmix/openpmix/releases
#
# @param ensure       [String]  Default: 'present'
#          Ensure the presence (or absence) of building
# @param target [String] Default: '/usr/local/src'
#          Target directory for the downloaded sources
# @param checksum_type [String] Default: 'sha1'
#          archive file checksum type (none|md5|sha1|sha2|sh256|sha384| sha512).
# @param checksum_verify [Boolean] Default: false
#          whether checksum will be verified (true|false).
# @param checksum [String] Default: ''
#           archive file checksum (match checksum_type)
#
#
# @example install version 2.2.3 (latest at the time of writing)
#
#     slurm::pmix::download { '2.2.3':
#        ensure        => 'present',
#        checksum      => 'c4e41632fb923a6be377f589e674cf17a659ae83',
#        checksum_type => 'sha1',
#        target        => '/usr/local/src/',
#     }
#
define slurm::pmix::download(
  String  $ensure          = $slurm::params::ensure,
  String  $target          = $slurm::params::srcdir,
  String  $url             = '',
  String  $checksum        = '',
  String  $checksum_type   = $slurm::params::pmix_src_checksum_type,
  Boolean $checksum_verify = false,
)
{
  include ::slurm::params
  validate_legacy('String',  'validate_re',   $ensure, ['^present', '^absent'])
  validate_legacy('String',  'validate_re',   $name,   [ '\d+[\.-]?' ])

  # $name is provided at define invocation
  if $name =~ /pmix-(.*)\.tar\.bz2/ {  # Full archive name provided
  $archive = $name
  $version = $1
  }
  elsif ($name =~ /\d+[\.-]?/ ) {       # only the version was provided
  $version = $name
  $archive = "pmix-${version}.tar.bz2"
  }
  else { fail("Wrong specification for ${module_name}") }

  # URL from where to download the sources
  $source = empty($url) ? {
    true    => "${slurm::params::pmix_download_baseurl}/v${version}/${archive}",
    default => $url,
  }

  # Absolute path to the downloaded source file
  $path =  "${target}/${archive}"
  # $basename = basename($archive, '.tar.bz2')
  # $extract_path = "${target}/${basename}/"

  $real_checksum_type = empty($checksum) ? {
    true    => 'none',
    default => $checksum_type
  }

  # Download the sources using puppet-archive module
  archive { $archive:
    ensure          => $ensure,
    path            => $path,
    source          => $source,
    user            => $slurm::params::username,
    group           => $slurm::params::group,
    checksum_type   => $real_checksum_type,
    checksum_verify => ($checksum_verify or ! empty($checksum)),
    checksum        => $checksum,
    cleanup         => false,
    extract         => false,
    # extract         => true,
    # extract_path    => $target,
    creates         => $path,
  }
  if $ensure == 'absent' {
    file {$path:
      ensure  => $ensure,
      require => Archive[$archive],
    }
  }
  # else {
  #   file {$extract_path:
  #     ensure => 'directory',
  #     owner  => $slurm::params::username,
  #     group  => $slurm::params::group,
  #     mode   => '0755',
  #     before => Archive[$archive]
  #   }
  # }


}
