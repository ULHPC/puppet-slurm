# Test download of SLURM sources
#
# You can execute this manifest as follows in your vagrant box
#
#      sudo puppet apply -t /vagrant/tests/download.pp
#
node default {

  include ::slurm::params

  slurm::download { $::slurm::params::version:
    ensure => 'present',
  }
  slurm::download { 'slurm-16.05.10.tar.bz2':
    archived => true,
    checksum => '8216a75830ba6aa72df6ae49cdfaa725',
  }

}
