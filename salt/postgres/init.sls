postgres-dependencies:
  pkg.installed:
    - cache_valid_time: 30000
    - pkgs:
      - postgresql
    - requires:
    
postgres-no-copy-on-write:
  file.directory:
    - name: /var/lib/postgres
    - makedirs: True
  cmd.run:
    - name: chattr +C /var/lib/postgres