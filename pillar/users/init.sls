users:
  simon:
    state: present
    system: False
    fullname: Simon Tennant
    home: /home/simon
    groups: 
      - users
      - sudo-bunker.imaginator.com
      - ssh-bunker.imaginator.com
    shell: /bin/zsh
    password: $6$BbBIAlyO$Ykx2ued1LaLdckdN5yKscKDzblZx4K.49tZ0evP/NNfEk4rSQMtEg/vIEECGld9aPEfVCMyOveyC6sv0r.fBT.
    pubkey: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCnAqd49QrBxYj73kAw+YKChDgc8KEOKhUqYtoP1pI9FPYV5tegMVtwhvPfovc6NoquzsViRzvFXsdw3Sp/aUCzOLknbthohBG+HtqxTICxVE76DtplwvoHnfF94wHC1Fl6OlvDkQRaCySgGhk7JWaVJAytaBMSZpPaAg+wlisCXpHAn36glpJv5Z9yHpK2XZ6NduYO7SqB0kYwKkLjBAjRjvQDhLdKtutVp00hHnefnTJlY8Q44UMqMomW/WL4XtjerttD59UCsPlnvtbKCWpOGAHLQlfpeqVnCpZp4eVpIRE7j/3E2CaNFc0qTK0mqnaH1Yk/6fQXQl1sgdYvq9Y8I8462irZrPuRrkgNAV6YKaUqven19nNLuybhq0cRG4K9lOZwTvvTyiMlRwo8uXawOwYoBAK+UiuCtoVvOo/+HkwCOFAU78LO8DyFGi3dLyZ6yy1jYSSuKOiSO2CuqHTszc0XE5E1bYWlua6hZoWa+agK4/zcvn6H+hy13xVOgcAMtjD4bVzYj2Wxqa4jSL0ye2m2FDE5LaEOyJLIYQ23hobrE2KvqRB/ALWLhvqJe5qUKDSWGkZvCyVArreaaLfUabcVZfdzmajt86suJJbfFQp9Dg5VHwIW6SssPL5NUNtHbfgoW7JCBXc64+nxmQqzHkcvBjahgEE+84/9zPKOqQ== simon@bunker.imaginator.com
  ryan:
    state: present
    fullname: Ryan Groch
    system: False
    password: $6$w.............adsdssssssssss
    home: /home/ryan
    groups: 
      - ssh-bunker.imaginator.com
      - users
    shell: /bin/bash
    pubkey: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTk9la+IUWicettutDFjBKDomWjpg2kx8CHFpaiahRQvhMy6OrLKn5GL04tRZJ1rMbPh8DULaqe6TKEySkTPVVsbvSJkqU9PUQsynQD5aBEd6trZX0bps9GQXXXxnewmT/CIA4jgxToKGYLG1LAZR9p8xdbJ3zxj7zrMurMMp9WpBy/NwonlGnVX/02Qu2xa+7gvc00zEFG2KNAGIv/KIuFE+9G8VxCkiErap6VmBesnVZDIMCKA+RR2zCUy+0GK/swujB0rZaF5cfythyIHXc0SMtJelk3AKHT19qytc+3g9JcGDbsE0ZbHYN9fQQAiNLbdrY/nZDVGCfM9ygX4Zl ryan@bunker
#  montyzuma:
#    user.absent
