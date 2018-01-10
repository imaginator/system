/usr/bin/salt "*" state.highstate -l quiet:
  cron.present:
    - identifier: salt-nightly-run
    - user: root
    - minute: random
    - hour: 2
