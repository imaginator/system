salt-master:
  service.running:
    - enable: True
    - running: True

/usr/bin/salt "*" state.highstate --state-output=mixed:
  cron.present:
    - identifier: salt-nightly-run
    - user: root
    - minute: random
    - hour: 2
