################################################################################
# Time-stamp: <Fri 2017-08-25 11:59 svarrette>
#
# File::      <tt>init.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# == Class: slurm
#
# The main slurm class, responsible for validating the parameters, and automate
# the provisioning and management of the daemons and compute nodes in a
# RedHat/CentOS based SLURM infrastructure.
# Slurm (A Highly Scalable Resource Manager) is an open source, fault-tolerant,
# and highly scalable cluster management and job scheduling system for large and
# small Linux clusters.
#
# More details on <https://slurm.schedmd.com/>
#
# @param ensure [String] Default: 'present'.
#         Ensure the presence (or absence) of slurm
####################### Main system configs #######################################
# @param uid                      [Integer]     Default: 991
# @param gid                      [Integer]     Default: as $uid
# @param version                  [String]      Default: '17.02.7'
# @param with_slurmd              [Boolean]     Default: true
# @param with_slurmctld           [Boolean]     Default: false
# @param with_slurmdbd            [Boolean]     Default: false
# @param wrappers                 [Array]       Default: [ 'slurm-openlava',  'slurm-torque' ]
########################                       ####################################
######################## slurm.conf attributes ####################################
########################                       ####################################
# @param configdir                [String]      Default: '/etc/slurm'
# @param clustername              [String]      Default: 'cluster'
#          The name by which this Slurm managed cluster is known in the accounting database
# @param authtype                 [String]      Default: 'munge'
#          Elligible values in [ 'none', 'munge' ]
# @param authinfo                 [String]      Default: ''
# @param cryptotype               [String]      Default: 'munge'
#          Elligible values in [ 'munge', 'openssl']
# @param backupcontroller         [String]      Default: ''
# @param backupaddr               [String]      Default: ''
# @param controlmachine           [String]      Default: $:hostname
# @param controladdr              [String]      Default: ''
# @param batchstarttimeout        [Integer]     Default: 10
# @param checkpointtype           [String]      Default: 'none'
#          Elligible values in ['blcr', 'none', 'ompi', 'poe']
# @param completewait             [Integer]     Default: 0
# @param corespecplugin           [String]      Default: 'none'
# @param cpufreqdef               [String]      Default: undef
#          Elligible values in ['Conservative', 'OnDemand', 'Performance', 'PowerSave']
# @param cpufreqgovernors         [Array]       Default: [ 'OnDemand', 'Performance' ]
#           Elligible values in ['Conservative', 'OnDemand', 'Performance', 'PowerSave', 'UserSpace' ]
# @param debugflags               [Array]       Default: []
# @param defmempercpu             [Integer]     Default: 0
#           0 = unlimited, mutually exclusive with $defmempernode
# @param maxmempercpu             [Integer]     Default: 0
#           0 = unlimited
# @param maxmempernode            [Integer]     Default: undef
# @param defmempernode            [Integer]     Default: undef
#           0 = unlimited, mutually exclusive with $defmempercpu
# @param disablerootjobs          [Boolean]     Default: true
# @param enforcepartlimits        [String]      Default: 'ALL'
# @param epilog                   [String]      Default: ''
# @param epilogslurmctld          [String]      Default: ''
# @param fastschedule             [Integer]     Default: 1
#           Elligible values in [ 0, 1, 2]
# @param grestypes                [Array]       Default: []
#           list of generic resources to be managed
# @param healthcheckinterval      [Integer]     Default: 30
# @param healthchecknodestate     [String]      Default: 'ANY'
#           Elligible values in ['ALLOC', 'ANY','CYCLE','IDLE','MIXED']
# @param healthcheckprogram       [String]      Default: ''
# @param inactivelimit            [Integer]     Default: 0
#           0 = unlimited
# @param jobacctgathertype        [String]      Default: 'cgroup'
#           Elligible values in [ "linux", "cgroup", "none"]
# @param jobacctgatherfrequency   [Integer]     Default: 30
# @param jobacctgatherparams      [String]      Default: ''
#           Elligible values in [ 'NoShared', 'UsePss', 'NoOverMemoryKill']
# @param jobcheckpointdir         [String]      Default: ''
# @param jobcomphost              [String]      Default: ''
#            machine hosting the job completion database
# @param jobcomploc               [String]      Default: 'slurmjobs'
#           where job completion records are written (DB name, filename...)
# @param jobcomptype              [String]      Default: 'none'
#           Elligible values in ["none", "elasticsearch", "filetxt", "mysql", "script"]
# @param jobcontainertype         [String]      Default: 'none'
#           Elligible values in ['cncu', 'none'] (CNCU = Compute Node Clean Up on Cray)
# @param jobsubmitplugins         [Array]       Default: [ 'lua' ]
# @param killwait                 [Integer]     Default: 30
#           interval (in seconds) given to a jobs processes between the SIGTERM and SIGKILL
# @param launchtype               [String]      Default: 'slurm'
# @param licenses                 [String]      Default: ''
#           Specification of licenses
# @param maildomain               [String]      Default: $::domain
# @param mailprog                 [String]      Default: '/bin/mail'
# @param maxtaskspernode          [Integer]     Default: 512
# @param mpidefault               [String]      Default: 'none'
#           Default type of MPI to be used. Srun may override this configuration parameter in any case.
#           Elligible values in ['lam','mpich1_p4','mpich1_shmem','mpichgm','mpichmx','mvapich','none','openmpi','pmi2']
# @param mpiparams                [String]      Default: ''

# @param preemptmode              [Array]       Default: [ 'REQUEUE' ]
#           in ['OFF','CANCEL','CHECKPOINT','GANG','REQUEUE','SUSPEND']
# @param preempttype              [String]      Default: 'qos'
#           in ['none', 'partition_prio', 'qos']
# @param prioritydecayhalflife    [String]      Default: '5-0'
#           aka 5 days
# @param priorityflags            [Array]       Default: []
# @param prioritytype             [String]      Default: 'multifactor'
#           Elligible values in ['basic', 'multifactor']
# @param priorityweightage        [Integer]     Default: 0
# @param priorityweightfairshare  [Integer]     Default: 0
# @param priorityweightjobsize    [Integer]     Default: 0
# @param priorityweightpartition  [Integer]     Default: 0
# @param priorityweightqos        [Integer]     Default: 0
# @param privatedata              [String]      Default: []
#           Elligible values in ['accounts','cloud','jobs','nodes','partitions','reservations','usage','users']
# @param proctracktype            [String]      Default: 'cgroup'
#           Elligible values in ['cgroup', 'cray', 'linuxproc', 'lua', 'sgi_job','pgid']

# @param prolog                   [String]      Default: ''
# @param prologflags              [Array]       Default: []
# @param prologslurmctld          [String]      Default: ''
# @param propagateresourcelimits  [Array]       Default: []
# @param propagateresourcelimits_except [Array] Default: ['MEMLOCK']

# @param returntoservice          [Integer]     Default: 1
#           Elligible values in [0, 1, 2]
# @param schedulertype            [String ]     Default: 'backfill'
#           Elligible values in ['backfill', 'builtin', 'hold']
# @param selecttype               [String ]     Default: 'cons_res'
#           Elligible values in ['bluegene','cons_res','cray','linear','serial' ]
# @param selecttype_params        [Array  ]     Default: [ 'CR_Core_Memory', 'CR_CORE_DEFAULT_DIST_BLOCK' ]

# @param slurmctlddebug           [String ]     Default: 'info'
# @param slurmddebug              [String ]     Default: 'info'

# @param slurmctldport            [Integer]     Default: 6817
# @param slurmdport               [Integer]     Default: 6818
# @param srunportrange            [String ]     Default: '50000-53000'
# @param srunepilog               [String ]     Default: ''
# @param srunprolog               [String ]     Default: ''
# @param switchtype               [String ]     Default: 'none'
#           Elligible values in ['nrt', 'none']
# @param taskepilog               [String ]     Default: ''
# @param taskplugin               [String ]     Default: 'cgroup'
#           Elligible values in ['affinity', 'cgroup','none']
# @param taskpluginparams         [Array  ]     Default: ['cpusets']
# @param taskprolog               [String ]     Default: ''
# @param tmpfs                    [String ]     Default: '/tmp'
# @param waittime                 [Integer]     Default: 0
############################                          ####################################
############################ topology.conf attributes ####################################
############################                          ####################################
# @param topology                 [String ]     Default:  = none
#           Which topology plugin to be used for determining the network topology and
#           optimizing job allocations to minimize network contention
#           Elligible values
#             3d_torus  -- best-fit logic over three-dimensional topology
#             node_rank -- orders nodes based upon information a node_rank field in the
#                 node record as generated by a select plugin. Slurm performs a best-fit
#                 algorithm over those ordered nodes
#             none -- default for other systems, best-fit logic over one-dimensional topology
#             tree -- used for a hierarchical network as described in a topology.conf file
# @param topology_content         [String]      Default: undef
#           The desired contents of a topology file, as a string. This attribute is
#           mutually exclusive with topology_source and topology_target.
# @param topology_source          [String]      Default: undef
#          A source topology file, which will be copied into place on the local system.
#          This attribute is mutually exclusive with topology_{content,target}.
# @param topology_target          [String]      Default: undef
#          Target link path
# @param topology_tree            [Hash]     Default:  {}
#          Hash defining the hierarchical network topology iff $topology == 'tree'
#          Format
#          'switchname' => {
  #              [comment => 'This will become a comment above the line',]
  #              nodes => '<nodes>',
  #              [linkspeed => '<speed>']
  #        }
#        Example
#        { 's0' => { nodes => 'dev[0-5]'   },
#          's1' => { nodes => 'dev-[6-11]' },
#          's2' => { nodes => 'dev-[12-17]'},
#          's3' => { comment   => 'GUID: XXXXXX - switch 0',
  #                  switches  => 's[0-2]',
  #                  linkspeed => '100Mb/s',} }
#       Which will produce the following entries in the topology.conf file
#           SwitchName=s0 Nodes=dev[0-5]
#           SwitchName=s1 Nodes=dev-[6-11]
#           SwitchName=s2 Nodes=dev-[12-17]
#           # GUID: XXXXXX - switch 0
#           SwitchName=s3 Switches=s[0-2] LinkSpeed=100Mb/s




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
# @example Default instance
#
#     include 'slurm'
#
# You can then specialize the various aspects of the configuration,
# for instance
#
#         class { 'slurm':
  #             ensure => 'present'
  #         }
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
class slurm(
  String  $ensure                         = $slurm::params::ensure,
  Integer $uid                            = $slurm::params::uid,
  Integer $gid                            = $slurm::params::gid,
  String  $version                        = $slurm::params::version,
  Boolean $with_slurmd                    = $slurm::params::with_slurmd,
  Boolean $with_slurmctld                 = $slurm::params::with_slurmctld,
  Boolean $with_slurmdbd                  = $slurm::params::with_slurmdbd,
  Array   $wrappers                       = $slurm::params::wrappers,
  #
  # Main configuration paramaters
  #
  String  $configdir                      = $slurm::params::configdir,
  String  $clustername                    = $slurm::params::clustername,
  String  $authtype                       = $slurm::params::authtype,
  String  $authinfo                       = $slurm::params::authinfo,
  String  $cryptotype                     = $slurm::params::cryptotype,
  String  $backupcontroller               = $slurm::params::backupcontroller,
  String  $backupaddr                     = $slurm::params::backupaddr,
  String  $controlmachine                 = $slurm::params::controlmachine,
  String  $controladdr                    = $slurm::params::controladdr,
  #
  Integer $batchstarttimeout              = $slurm::params::batchstarttimeout
  String  $checkpointtype                 = $slurm::params::checkpointtype
  Integer $completewait                   = $slurm::params::completewait
  String  $corespecplugin                 = $slurm::params::corespecplugin
  $cpufreqdef                             = $slurm::params::cpufreqdef
  Array   $cpufreqgovernors               = $slurm::params::cpufreqgovernors
  Array   $debugflags                     = $slurm::params::debugflags
  #
  Integer $defmempercpu                   = $slurm::params::defmempercpu
  Integer $maxmempercpu                   = $slurm::params::maxmempercpu
  $maxmempernode                          = $slurm::params::maxmempernode
  $defmempernode                          = $slurm::params::defmempernode
  #
  Boolean $disablerootjobs                = $slurm::params::disablerootjobs
  String  $enforcepartlimits              = $slurm::params::enforcepartlimits
  String  $epilog                         = $slurm::params::epilog
  String  $epilogslurmctld                = $slurm::params::epilogslurmctld
  Integer $fastschedule                   = $slurm::params::fastschedule
  Array   $grestypes                      = $slurm::params::grestypes
  Integer $healthcheckinterval            = $slurm::params::healthcheckinterval
  String  $healthchecknodestate           = $slurm::params::healthchecknodestate
  String  $healthcheckprogram             = $slurm::params::healthcheckprogram
  Integer $inactivelimit                  = $slurm::params::inactivelimit
  String  $jobacctgathertype              = $slurm::params::jobacctgathertype
  Integer $jobacctgatherfrequency         = $slurm::params::jobacctgatherfrequency
  String  $jobacctgatherparams            = $slurm::params::jobacctgatherparams
  String  $jobcheckpointdir               = $slurm::params::jobcheckpointdir
  String  $jobcomphost                    = $slurm::params::jobcomphost
  String  $jobcomploc                     = $slurm::params::jobcomploc
  String  $jobcomptype                    = $slurm::params::jobcomptype
  String  $jobcontainertype               = $slurm::params::jobcontainertype
  Array   $jobsubmitplugins               = $slurm::params::jobsubmitplugins
  Integer $killwait                       = $slurm::params::killwait
  String  $launchtype                     = $slurm::params::launchtype
  String  $licenses                       = $slurm::params::licenses
  String  $maildomain                     = $slurm::params::maildomain
  String  $mailprog                       = $slurm::params::mailprog
  Integer $maxtaskspernode                = $slurm::params::maxtaskspernode
  # Default type of MPI to be used.
  String  $mpidefault                     = $slurm::params::mpidefault
  String  $mpiparams                      = $slurm::params::mpiparams
  #
  Array   $preemptmode                    = $slurm::params::preemptmode
  String  $preempttype                    = $slurm::params::preempttype
  String  $prioritydecayhalflife          = $slurm::params::prioritydecayhalflife
  Array   $priorityflags                  = $slurm::params::priorityflags
  String  $prioritytype                   = $slurm::params::prioritytype
  Integer $priorityweightage              = $slurm::params::priorityweightage
  Integer $priorityweightfairshare        = $slurm::params::priorityweightfairshare
  Integer $priorityweightjobsize          = $slurm::params::priorityweightjobsize
  Integer $priorityweightpartition        = $slurm::params::priorityweightpartition
  Integer $priorityweightqos              = $slurm::params::priorityweightqos
  String  $privatedata                    = $slurm::params::privatedata
  String  $proctracktype                  = $slurm::params::proctracktype
  #
  String  $prolog                         = $slurm::params::prolog
  Array   $prologflags                    = $slurm::params::prologflags
  String  $prologslurmctld                = $slurm::params::prologslurmctld
  Array   $propagateresourcelimits        = $slurm::params::propagateresourcelimits
  Array   $propagateresourcelimits_except =  $slurm::params::propagateresourcelimits_excep
  Integer $returntoservice                = $slurm::params::returntoservice
  String  $schedulertype                  = $slurm::params::schedulertype
  String  $selecttype                     = $slurm::params::selecttype
  Array   $selecttype_params              = $slurm::params::selecttype_params
  # Log details
  String  $slurmctlddebug                 = $slurm::params::slurmctlddebug
  String  $slurmddebug                    = $slurm::params::slurmddebug
  # Ports
  Integer $slurmctldport                  = $slurm::params::slurmctldport
  Integer $slurmdport                     = $slurm::params::slurmdport
  String  $srunportrange                  = $slurm::params::srunportrange
  String  $srunepilog                     = $slurm::params::srunepilog
  String  $srunprolog                     = $slurm::params::srunprolog
  String  $switchtype                     = $slurm::params::switchtype
  String  $taskepilog                     = $slurm::params::taskepilog
  String  $taskplugin                     = $slurm::params::taskplugin
  Array   $taskpluginparams               = $slurm::params::taskpluginparams
  String  $taskprolog                     = $slurm::params::taskprolog
  String  $tmpfs                          = $slurm::params::tmpfs
  Integer $waittime                       = $slurm::params::waittime
  #
  # Which topology plugin to be used for determining the network topology and
  # optimizing job allocations to minimize network contention
  String  $topology                       = $slurm::params::topology,
  #
  # cgroup.conf
  #
  $cgroup_content                         = undef,
  $cgroup_source                          = undef,
  $cgroup_target                          = undef,
  Boolean $cgroup_automount               = $slurm::params::cgroup_automount,
  String  $cgroup_mountpoint              = $slurm::params::cgroup_mountpoint,
  Array   $cgroup_alloweddevices          = $slurm::params::cgroup_alloweddevices,
  $cgroup_allowedkmemspace                = $slurm::params::cgroup_allowedkmemspace,
  Numeric $cgroup_allowedramspace         = $slurm::params::cgroup_allowedramspace,
  Numeric $cgroup_allowedswapspace        = $slurm::params::cgroup_allowedswapspace,
  Boolean $cgroup_constraincores          = $slurm::params::cgroup_constraincores,
  Boolean $cgroup_constraindevices        = $slurm::params::cgroup_constraindevices,
  Boolean $cgroup_constrainkmemspace      = $slurm::params::cgroup_constrainkmemspace,
  Boolean $cgroup_constrainramspace       = $slurm::params::cgroup_constrainramspace,
  Boolean $cgroup_constrainswapspace      = $slurm::params::cgroup_constrainswapspace,
  Numeric $cgroup_maxrampercent           = $slurm::params::cgroup_maxrampercent,
  Numeric $cgroup_maxswappercent          = $slurm::params::cgroup_maxswappercent,
  Numeric $cgroup_maxkmempercent          = $slurm::params::cgroup_maxkmempercent,
  String  $cgroup_minkmemspace            = $slurm::params::cgroup_minkmemspace,
  String  $cgroup_minramspace             = $slurm::params::cgroup_minramspace,
  Boolean $cgroup_taskaffinity            = $slurm::params::cgroup_taskaffinity,
  #
  # gres.conf
  #
  $gres_content  = undef,
  $gres_source   = undef,
  $gres_target   = undef,
  Hash    $gres  = {},
  #
  # topology.conf
  #
  $topology_content      = undef,
  $topology_source       = undef,
  $topology_target       = undef,
  Hash    $topology_tree = {},
  #
  # Slurm source building
  # TODO: option NOT to build but re-use shared RPMs
  Boolean $src_archived  = $slurm::params::src_archived,
  String  $src_checksum  = $slurm::params::src_checksum,
  String  $srcdir        = $slurm::params::srcdir,
  String  $builddir      = $slurm::params::builddir,
  #
  # Munge authentication service
  #
  Boolean $use_munge          = $slurm::params::use_munge,
  Boolean $munge_create_key   = $slurm::params::munge_create_key,
  Array   $munge_daemon_args  = $slurm::params::munge_daemon_args,
  $munge_key_source           = undef,
  $munge_key_content          = undef,
  String  $munge_key_filename = $slurm::params::munge_key,
  Integer $munge_uid          = $slurm::params::munge_uid,
  Integer $munge_gid          = $slurm::params::munge_gid,
  #
  # PAM settings
  #
  Boolean $use_pam             = $slurm::params::use_pam,
  String  $pam_content         = $slurm::params::pam_content,
  Array   $pam_allowed_users   = $slurm::params::pam_allowed_users,
  String  $pam_limits_source   = $slurm::params::pam_limits_source,
  Boolean $use_pam_slurm_adopt = $slurm::params::use_pam_slurm_adopt,
)
inherits slurm::params
{
  validate_legacy('String', 'validate_re', $ensure, ['^present', '^absent'])

  info ("Configuring SLURM (with ensure = ${ensure})")

  case $::operatingsystem {
    #debian, ubuntu:         { include ::slurm::common::debian }
    'redhat', 'fedora', 'centos': { include ::slurm::common::redhat }
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }
}
