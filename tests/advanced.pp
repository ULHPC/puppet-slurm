# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation
# errors and view a log of events) or by fully applying the test in a virtual
# environment (to compare the resulting system state to the desired state).
#
# Learn more about module testing here
# http://docs.puppetlabs.com/guides/tests_smoke.html
#
#
#
# You can execute this manifest as follows in your vagrant box
#
#      sudo puppet apply -t /vagrant/tests/init.pp
#
node default {
  include ::slurm::params

  # Example of the topology tree
  $tree = {
    's0' => { nodes => 'dev[0-5]'   },
    's1' => { nodes => 'dev-[6-11]' },
    's2' => { nodes => 'dev-[12-17]'},
    's3' => {
      comment   => 'GUID: XXXXXX - switch 0',
      switches  => 's[0-2]',
      linkspeed => '100Mb/s', },
  }
  # Definition of the nodes
  $nodes = {
    'DEFAULT'    => {
      comment => 'Test',
      content => 'CPUs=1 Sockets=1 CoresPerSocket=1 ThreadsPerCore=1 RealMemory=512 State=UP', },
    'access'     => 'CPUs=2 Sockets=1 CoresPerSocket=2 ThreadsPerCore=1 State=UNKNOWN',
    'thor-[1-3]' => 'CPUs=2 Sockets=1 CoresPerSocket=2 ThreadsPerCore=1  RealMemory=400 State=UNKNOWN',
  }
  # Definition of the partitions
  $partitions = {
    'interactive' => {
      content  => 'Nodes=thor-1 State=UP DefaultTime=0-10:00:00 MaxTime=5-00:00:00 DisableRootJobs=YES ',
      priority => 0, },
    'batch'       => {
      content => 'Nodes=thor-[2-3]  State=UP  DefaultTime=0-2:00:00 MaxTime=5-00:00:00 DisableRootJobs=YES',
      priority => 100,
      preempt  => 'qos-interactive',
      #default  => true,
    },
  }

  # Let's go, all-in-one run
  class { '::slurm':
    with_slurmdbd  => true,
    with_slurmctld => true,
    topology       => 'tree',
    topology_tree  => $tree,
    nodes          => $nodes,
    partitions     => $partitions,
  }
}
