# https://slurm.schedmd.com/slurm.conf.html
type Slurm::SchedulerType = Enum[
  'backfill',
  'builtin',
  'hold',
]
