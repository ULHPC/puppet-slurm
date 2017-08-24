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

  class { '::slurm':
    pam_allowed_users => [ 'vagrant' ],
    topology      => 'tree',
    topology_tree => {
      's0' => { nodes => 'dev[0-5]'   },
      's1' => { nodes => 'dev-[6-11]' },
      's2' => { nodes => 'dev-[12-17]'},
      's3' => {
        comment   => 'GUID: XXXXXX - switch 0',
        switches  => 's[0-2]',
        linkspeed => '100Mb/s',
      },
    },


  }

  # slurm::download { $::slurm::params::version:
    #   #checksum => '64009c1ed120b9ce5d79424dca743a06'
    # }
  # slurm::download { 'slurm-16.05.10.tar.bz2':
    #   archived => true,
    #   checksum => '8216a75830ba6aa72df6ae49cdfaa725',
    # }

}
