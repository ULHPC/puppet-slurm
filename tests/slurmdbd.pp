#
# You can execute this manifest as follows in your vagrant box
#
#      sudo puppet apply -t /vagrant/tests/slurmdbd.pp
#
node default {
  # include ::slurm::params

  include ::slurm
  include ::slurm::slurmdbd

}
