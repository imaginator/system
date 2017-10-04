remove-junk:
  pkg.purged:
    - name: nano

install-base-utils:
  pkg.installed:
    - names: 
      - tmux
      - zsh
      - git
      - htop
      - vim
      - tcpdump

  

