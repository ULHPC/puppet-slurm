#
# You can execute this manifest as follows in your vagrant box
#
#      sudo puppet apply -t /vagrant/tests/repo.pp
#
node default {

  class { '::slurm::repo':
    ensure => 'present',
    source => 'ssh://git@github.com/ULHPC/slurm-control.git',
  }

}
