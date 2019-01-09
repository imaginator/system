#redirect root emails

cron_mail_admin:
  cron.env_present:
    - user: root
    - name: MAILTO
    - value: simon@imaginator.com
