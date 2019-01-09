remove-junk:
  pkg.purged:
    - name: nano

install-base-utils:
  pkg.installed:
    - names: 
      - tmux
      - zsh
      - curl
      - git
      - htop
      - vim
      - tcpdump
      - iptables-persistent
      - snapper
      - iotop
