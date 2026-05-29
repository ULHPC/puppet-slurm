# Class: slurm::config::namespace_plugins
#     Configure slurm Namespace Plugins.
#     see: https://slurm.schedmd.com/namespace.html
#
# @param auto_base_path
# @param base_path
#
class slurm::config::namespace_plugins (
  Boolean $auto_base_path = true,
  String $base_path = '/var/slurm/namespaces',
) inherits slurm::config {
  case ($slurm::namespacetype) {
    'linux': {
      file { "${slurm::configdir}/namespace.yaml":
        ensure  => file,
        content => template('slurm/namespace.yaml.erb'),
      }
    }
    'tmpfs': {
      file { "${slurm::configdir}/job_container.conf":
        ensure  => file,
        content => template('slurm/job_container.conf.erb'),
      }
    }
    default: {}
  }
}
