################################################################################
# Time-stamp: <Fri 2017-10-06 00:41 svarrette>
#
# File::      <tt>slurmdbd.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# == Class: slurm::slurmdbd
#
# This class is responsible for setting up a Slurm Database Daemon, which
# provides a secure enterprise-wide interface to a database for Slurm.
# In particular, it can run relatively independently of the other slurm daemon
# instances and thus is proposed as a separate independent class.
#
# More details on <https://slurm.schedmd.com/slurmdbd.html>
# See also <https://slurm.schedmd.com/slurmdbd.conf.html>
#
# @param ensure [String] Default: 'present'.
#         Ensure the presence (or absence) of slurm
# @param content [String]
#          The desired contents of a file, as a string. This attribute is
#          mutually exclusive with source and target.
#          See also
#          https://docs.puppet.com/puppet/latest/types/file.html#file-attribute-content
# @param source  [String]
#          A source file, which will be copied into place on the local system.
#          This attribute is mutually exclusive with content and target.
#          See also
#          https://docs.puppet.com/puppet/latest/types/file.html#file-attribute-source
# @param target  [String]
#          See also
#          https://docs.puppet.com/puppet/latest/types/file.html#file-attribute-target
#
########################                          ####################################
######################## slurmdbd.conf attributes ####################################
########################                          ####################################
#
# @param configdir          [String]      Default: '/etc/slurm'
# @param authtype           [String]      Default: 'munge'
#          Elligible values in [ 'none', 'munge' ]
# @param authinfo           [String]      Default: ''
# @param privatedata        [Array]       Default: []
#           Elligible values in ['accounts','jobs','reservations','usage','users']
# @param archiveevents      [Boolean]     Default: false
#           When purging events also archive them?
# @param archivejobs        [Boolean]     Default: false
#           When purging jobs also archive them?
# @param archiveresv        [Boolean]     Default: false
#           When purging reservations also archive them?
# @param archivesteps       [Boolean]     Default: false
#           When purging steps also archive them?
# @param archivesuspend     [Boolean]     Default: false
#           When purging suspend data also archive it?
# @param archivetxn         [Boolean]     Default: false
#           When purging transaction data also archive it?
# @param archiveusage       [Boolean]     Default: false
#           When purging usage data (Cluster, Association and WCKey) also archive it.
# @param commitdelay        [Integer]     Default: 0
# @param dbhost             [String]      Default: localhost
#           The short, or long, name of the machine where the Slurm Database Daemon is executed
# @param dbdbackuphost      [String]      Default: ''
#           The short, or long, name of the machine where the backup Slurm Database Daemon is executed
# @param dbdaddr            [String]      Default: localhost
#           Name that DbdHost should be referred to in establishing a communications path
# @param dbddport           [Integer]     Default: 6819
#           The port number that the Slurm Database Daemon (slurmdbd) listens to for work.
# @param debuglevel         [String ]     Default: info
#           The level of detail to provide the Slurm Database Daemon's logs.
# @param debugflags         [String ]     Default: []
#           in ['DB_ARCHIVE','DB_ASSOC','DB_EVENT','DB_JOB','DB_QOS','DB_QUERY','DB_RESERVATION','DB_RESOURCE','DB_STEP','DB_USAGE','DB_WCKEY']
# @param storagehost        [String]      Default: $::hostname
# @param storagebackuphost  [String]      Default: ''
# @param storageloc         [String]      Default: 'slurm'
# @param storageport        [Integer]     Default: 3306
# @param storagetype        [String]      Default: 'mysql'
# @param storageuser        [String]      Default: 'slurm'
# @param trackslurmctlddown [Boolean]     Default: false
# @param bootstrap_mysql    [Boolean]     Default: true
#
# === Authors
#
# The UL HPC Team <hpc-sysadmins@uni.lu> of the University of Luxembourg, in
# particular
# * Sebastien Varrette <Sebastien.Varrette@uni.lu>
# * Valentin Plugaru   <Valentin.Plugaru@uni.lu>
# * Sarah Peter        <Sarah.Peter@uni.lu>
# * Hyacinthe Cartiaux <Hyacinthe.Cartiaux@uni.lu>
# * Clement Parisot    <Clement.Parisot@uni.lu>
#
# === Warnings
#
# /!\ Always respect the style guide available here[http://docs.puppetlabs.com/guides/style_guide]
#
# [Remember: No empty lines between comments and class definition]
#
class slurm::slurmdbd(
  String  $ensure             = $slurm::ensure,
  $content                    = undef,
  $source                     = undef,
  $target                     = undef,
  #
  # Main configuration paramaters
  #
  String  $archivedir         = $slurm::params::archivedir,
  Boolean $archiveevents      = $slurm::params::archiveevents,
  Boolean $archivejobs        = $slurm::params::archivejobs,
  Boolean $archiveresv        = $slurm::params::archiveresv,
  Boolean $archivesteps       = $slurm::params::archivesteps,
  Boolean $archivesuspend     = $slurm::params::archivesuspend,
  Boolean $archivetxn         = $slurm::params::archivetxn,
  Boolean $archiveusage       = $slurm::params::archiveusage,
  Integer $commitdelay        = $slurm::params::commitdelay,
  String  $dbdhost            = $slurm::params::dbdhost,
  String  $dbdaddr            = $slurm::params::dbdaddr,
  String  $dbdbackuphost      = $slurm::params::dbdbackuphost,
  Integer $dbdport            = $slurm::params::slurmdbdport,
  String  $debuglevel         = $slurm::params::slurmdbddebug,
  Array   $debugflags         = $slurm::params::debugflags,
  $purgeeventafter            = undef,
  $purgejobafter              = undef,
  $purgeresvafter             = undef,
  $purgestepafter             = undef,
  $purgesuspendafter          = undef,
  $purgetxnafter              = undef,
  $purgeusageafter            = undef,
  String  $storagehost        = $slurm::params::storagehost,
  String  $storagebackuphost  = $slurm::params::storagebackuphost,
  String  $storageloc         = $slurm::params::storageloc,
  String  $storagepass        = $slurm::params::storagepass,
  Integer $storageport        = $slurm::params::storageport,
  String  $storagetype        = $slurm::params::storagetype,
  String  $storageuser        = $slurm::params::storageuser,
  Boolean $trackslurmctlddown = $slurm::params::trackslurmctlddown,
  Boolean $bootstrap_mysql    = $slurm::params::bootstrap_mysql,
)
inherits slurm
{
  validate_legacy('String', 'validate_re', $ensure, ['^present', '^absent'])

  case $::osfamily {
    'Redhat': { }
    default:  { fail("Module ${module_name} is not supported on ${::operatingsystem}") }
  }

  include ::slurm::install
  include ::slurm::config
  Class['slurm::install'] -> Class['slurm::config']

  if $slurm::manage_firewall {
    slurm::firewall { "${dbdport}":
      ensure => $slurm::ensure,
    }
  }


  # [Eventually] bootstrap the MySQL DB
  if $bootstrap_mysql == true {
    # you now need to  allow remote access from a different host rather than
    # localhost within /etc/my.cnf.d/server.cnf i.e. $mysql::server::config_file
    # i.e. comment the line
    # [mysqld]
    # ...
    # bind-address = 127.0.0.1
    if $storagehost != 'localhost' {
      $bind_setting = $ensure ? {
        'present' => '0.0.0.0',
        default   => '127.0.0.1',
      }
    }
    class { '::mysql::server':
      override_options => {
        'mysqld' => {
          'bind-address' => $bind_setting,
        },
      },
    }

    include ::mysql::server::account_security

    mysql::db { $storageloc:
      user     => $storageuser,
      password => $storagepass,
      host     => $dbdhost,
      grant    => ['ALL'],
      before   => File[$slurm::params::dbd_configfile],
    }
    # Eventually create the 'slurm'@'*' user with all rights
    unique([ $storagehost, $::hostname, $::fqdn]).each |String $host| {
      mysql_user { "${storageuser}@${host}":
        password_hash => mysql_password($storagepass),
      }
      mysql_grant {  "${storageuser}@${host}/${storageloc}.*":
        privileges => ['ALL'],
        table      => "${storageloc}.*",
        user       => "${storageuser}@${host}",
        require    => Mysql_user["${storageuser}@${host}"],
        before     => File[$slurm::params::dbd_configfile],
      }
    }
  }

  # Now prepare the slurmdbd.conf
  $dbdconf_content = $content ? {
    undef   => $source ? {
      undef   => $target ? {
        undef   => template('slurm/slurmdbd.conf.erb'),
        default => $content,
      },
      default => $content
    },
    default => $content,
  }
  $dbdconf_ensure = $target ? {
    undef   => $ensure,
    default => $ensure ? {
      'present' => 'link',
      default   => $ensure,
    }
  }

  # slurmdbd.conf
  $filename = "${slurm::configdir}/${slurm::params::dbd_configfile}"
  file { $slurm::params::dbd_configfile:
    ensure  => $dbdconf_ensure,
    path    => $filename,
    owner   => $slurm::username,
    group   => $slurm::group,
    mode    => $slurm::params::dbd_configfile_mode,
    content => $dbdconf_content,
    source  => $source,
    target  => $target,
    #notify  => Service['slurmdbd'],
    # require => [
    #   Class['::slurm::config'],
    #   File[$slurm::configdir],
    # ],
  }
  if $slurm::ensure == 'present' {
    File[$slurm::params::dbd_configfile] {
      require => File[$slurm::configdir],
    }
  }

  if $slurm::service_manage == true {

    if $slurm::manage_accounting {
      # Ensure the cluster have been created
      slurm::acct::cluster{ $slurm::clustername:
        ensure  => $slurm::ensure,
        require => Service['slurmdbd'],
      }
    }

    File[$slurm::params::dbd_configfile] {
      notify  => Service['slurmdbd'],
    }

    service { 'slurmdbd':
      ensure     => ($ensure == 'present'),
      enable     => ($ensure == 'present'),
      name       => $slurm::params::dbd_servicename,
      pattern    => $slurm::params::dbd_processname,
      hasrestart => $slurm::params::hasrestart,
      hasstatus  => $slurm::params::hasstatus,
    }
    if $slurm::with_slurmd or defined(Class['slurm::slurmd']) {
      Service['slurmdbd'] -> Service['slurmd']
    }
    if $slurm::with_slurmctld or defined(Class['slurm::slurmctld']) {
      Service['slurmdbd'] -> Service['slurmctld']
    }

  }


}
