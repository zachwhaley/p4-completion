p4_completion
=============

Bash completion for Perforce.

Installation
------------

Copy or link `p4_completion.bash` to `/etc/bash_completion.d/`

```bash
# Linux
$ sudo cp p4_completion.bash /etc/bash_completion.d/p4
# OSX (Mac)
$ sudo cp p4_completion.bash /opt/local/etc/bash_completion.d/p4

# Or
# Linux
$ cd /etc/bash_completion.d/
# OSX (Mac)
$ cd /opt/local/etc/bash_completion.d/
$ sudo ln -s /path/to/p4_completion.bash p4
```

You can source the script in your `bashrc`, if `/etc/bash_completion.d/` does not exist in your setup.

```bash
$ echo "source /path/to/p4_completion.bash" >> ~/.bashrc
```
