# https://slurm.schedmd.com/slurm.conf.html
type Slurm::SelectType = Enum[
  'cons_res',
  'cray',
  'linear',
  'serial',
]
