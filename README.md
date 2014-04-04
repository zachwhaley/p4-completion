p4_completion
=============

Bash completion for Perforce.

Installation
------------

Copy or link `p4_completion.bash` to /etc/bash_completion.d/

```bash
$ sudo cp p4_completion.bash /etc/bash_completion.d/
# Or
$ cd /etc/bash_completion.d/
$ sudo ln -s /path/to/git_repo/p4_completion.bash p4_completion.bash
```

If bash_completion.d does not exist in your setup, create the directory and source it in your bashrc

```bash
$ sudo mkdir -p /etc/bash_completion.d
$ echo "for file in /etc/bash_completion.d/*; do source $file; done" >> ~/.bashrc
```
