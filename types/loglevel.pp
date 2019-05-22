# https://slurm.schedmd.com/slurm.conf.html
type Slurm::LogLevel = Enum[
  'quiet',
  'fatal',
  'error',
  'info',
  'verbose',
  'debug',
  'debug2',
  'debug3',
  'debug4',
  'debug5',
]
