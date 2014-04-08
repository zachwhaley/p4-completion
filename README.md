p4_completion
=============

Bash completion for Perforce.

Installation
------------

Copy or link `p4_completion.bash` to `/etc/bash_completion.d/`

```bash
$ sudo cp p4_completion.bash /etc/bash_completion.d/p4
# Or
$ cd /etc/bash_completion.d/
$ sudo ln -s /path/to/p4_completion.bash p4
```

You can source the script in your `bashrc`, if `/etc/bash_completion.d/` does not exist in your setup.

```bash
$ echo "source /path/to/p4_completion.bash" >> ~/.bashrc
```
