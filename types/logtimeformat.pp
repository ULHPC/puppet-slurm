# https://slurm.schedmd.com/slurm.conf.html
type Slurm::LogTimeFormat = Enum[
  'iso8601',
  'iso8601_ms',
  'rfc5424',
  'rfc5424_ms',
  'clock',
  'short',
  'thread_id',
]
