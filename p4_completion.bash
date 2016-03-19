# A bash completion script for Perforce 2015.2
# Author: Zach Whaley, zachbwhaley@gmail.com

# Takes one argument
# 1: String of commplete strings
function __p4_complete__()
{
    COMPREPLY=( $(compgen -W "$1" -- ${cur}) )
}

function __p4_filenames__()
{
    COMPREPLY=( $(compgen -f ${cur}) )
}

__p4_g_opts="-b -c -d -I -G -H -p -P -r -s -u -x -C -Q -L -z -q -V -h"

__p4_cmds="add annotate attribute branch branches change changes changelist changelists clean client clients copy counter counters cstat delete depot depots describe diff diff2 dirs edit filelog files fix fixes flush fstat grep group groups have help info integrate integrated interchanges istat job jobs key keys label labels labelsync list lock logger login logout merge move opened passwd populate print protect protects prune rec reconcile rename reopen resolve resolved revert review reviews set shelve status sizes stream streams submit sync tag tickets unlock unshelve update user users where workspace workspaces"

__p4_filetypes="text binary symlink apple resource unicode utf8 utf16"

__p4_streamtypes="mainline virtual development release task"

__p4_submitopts="submitunchanged submitunchanged+reopen revertunchanged revertunchanged+reopen leaveunchanged leaveunchanged+reopen"

__p4_change_status="pending shelved submitted"

__p4_help_keywords="simple commands charset environment filetypes jobview revisions usage views"

# Takes one argument
# 1: The Perforce environment variable to return
function __p4_var__()
{
    echo $(p4 set $1 | awk '{split($1,a,"="); print a[2]}')
}

function __p4_vars__()
{
    echo $(p4 set | awk -F'=' '{print $1}')
}

# Takes one argument
# 1: Status of the changes
function __p4_changes__()
{
    local client=$(__p4_var__ P4CLIENT)
    local user=$(__p4_var__ P4USER)
    if [ -z $1 ]; then
        echo $(p4 changes -c $client -u $user | awk '{print $2}')
    else
        echo $(p4 changes -c $client -u $user -s $1 | awk '{print $2}')
    fi
}

function __p4_users__()
{
   echo $(p4 users | awk '{print $1}')
}

function __p4_clients__()
{
    local user=$(__p4_var__ P4USER)
    echo $(p4 clients -u $user | awk '{print $2}')
}

function __p4_branches__()
{
    echo $(p4 branches | awk '{print $2}')
}

function __p4_counters__()
{
    echo $(p4 counters | awk '{print $1}')
}

function __p4_depots__()
{
    echo $(p4 depots | awk '{print $2}')
}

function __p4_groups__()
{
    echo $(p4 groups | awk '{print $2}')
}

function __p4_labels__()
{
    local user=$(__p4_var__ P4USER)
    echo $(p4 labels -u $user | awk '{print $2}')
}

function __p4_streams__()
{
    echo $(p4 streams | awk '{print $1}')
}

function __p4_jobs__()
{
    echo $(p4 jobs | awk '{print $1}')
}

function __p4_keys__()
{
    echo $(p4 keys | awk '{print $1}')
}

## Below are mappings to Perforce commands

# add -- Open a new file to add it to the depot
#
# p4 add [-c changelist#] [-d -f -I -n] [-t filetype] file ...
function _p4_add()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
        -t)
            __p4_complete__ "$__p4_filetypes"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-c -d -f -I -n -t"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# annotate -- Print file lines and their revisions
#
# p4 annotate [-aciIqtu -d<flags>] file[revRange] ...
function _p4_annotate()
{
    case "$cur" in
        -*)
            __p4_complete__ "-a -c -i -I -q -t -d"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# attribute -- Set per-revision attributes on revisions
#
# p4 attribute [-e -f -p] -n name [-v value] files...
# p4 attribute [-e -f -p] -i -n name file
function _p4_attribute()
{
    case "$cur" in
        -*)
            __p4_complete__ "-e -f -p -i -n -v"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# branch -- Create, modify, or delete a branch view specification
#
# p4 branch [-f] name
# p4 branch -d [-f] name
# p4 branch [ -S stream ] [ -P parent ] -o name
# p4 branch -i [-f]
function _p4_branch()
{
    case "$prev" in
        -S)
            __p4_complete__ "$(__p4_streams__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-f -d -S -P -o -i"
            ;;
        *)
            __p4_complete__ "$(__p4_branches__)"
            ;;
    esac
}

# branches -- Display list of branch specifications
#
# p4 branches [-t] [-u user] [[-e|-E] nameFilter -m max]
function _p4_branches()
{
    case "$prev" in
        -u)
            __p4_complete__ "$(__p4_users__)"
            return ;;
    esac

    __p4_complete__ "-t -u -e -E -m"
}

# change -- Create or edit a changelist description
# changelist -- synonym for 'change'
#
# p4 change [-s] [-f | -u] [[-O|-I] changelist#]
# p4 change -d [-f -s -O] changelist#
# p4 change -o [-s] [-f] [[-O|-I] changelist#]
# p4 change -i [-s] [-f | -u]
# p4 change -t restricted | public [-U user] [-f|-u|-O|-I] changelist#
# p4 change -U user [-t restricted | public] [-f] changelist#
# p4 change -d -f --serverid=X changelist#
function _p4_change()
{
    case "$prev" in
        -t)
            __p4_complete__ "restricted public"
            return ;;
        -U)
            __p4_complete__ "$(__p4_users__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-s -f -u -O -I -d -o -i -t -U"
            ;;
        *)
            __p4_complete__ "$(__p4_changes__ pending)"
    esac
}

# changes -- Display list of pending and submitted changelists
# changelists -- synonym for 'changes'
#
# p4 changes [-i -t -l -L -f] [-c client] [ -e changelist# ]
#     [-m max] [-s status] [-u user] [file[revRange] ...]
function _p4_changes()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_clients__)"
            return ;;
        -e)
            __p4_complete__ "$(__p4_changes__)"
            return ;;
        -s)
            __p4_complete__ "$__p4_change_status"
            return ;;
        -u)
            __p4_complete__ "$(__p4_users__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-i -t -l -L -f -c -e -m -s -u"
            ;;
        *)
            __p4_filenames__
    esac
}

# clean -- synonym for 'reconcile -w'
#
# p4 clean [-e -a -d -I -l -n] [file ...]
function _p4_clean()
{
    case "$cur" in
        -*)
            __p4_complete__ "-e -a -d -I -l -n"
            ;;
        *)
            __p4_filenames__
    esac
}

# client -- Create or edit a client workspace specification and its view
# workspace -- Synonym for 'client'
#
# p4 client [-f] [-t template] [name]
# p4 client -d [-f [-Fs]] name
# p4 client -o [-t template] [name]
# p4 client -S stream [[-c change] -o] [name]
# p4 client -s [-f] -S stream [name]
# p4 client -s [-f] -t template [name]
# p4 client -i [-f]
# p4 client -d -f --serverid=X [-Fs] name
function _p4_client()
{
    case "$prev" in
        -t)
            __p4_complete__ "$(__p4_clients__)"
            return ;;
        -c)
            __p4_complete__ "$(__p4_changes__)"
            return ;;
        -S)
            __p4_complete__ "$(__p4_streams__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-f -t -d -Fs -o -S -c -s -i"
            ;;
        *)
            __p4_complete__ "$(__p4_clients__)"
            ;;
    esac
}

# clients -- Display list of clients
# workspaces -- synonym for 'clients'
#
# p4 clients [-t] [-u user] [[-e|-E] nameFilter -m max] [-S stream]
#            [-a | -s serverID]
# p4 clients -U
function _p4_clients()
{
    case "$prev" in
        -u)
            __p4_complete__ "$(__p4_users__)"
            return ;;
        -S)
            __p4_complete__ "$(__p4_streams__)"
            return ;;
    esac

    __p4_complete__ "-t -u -e -E -m -S -a -s -U"
}

# copy -- Copy one set of files to another
#
# p4 copy [options] fromFile[rev] toFile
# p4 copy [options] -b branch [-r] [toFile[rev] ...]
# p4 copy [options] -b branch -s fromFile[rev] [toFile ...]
# p4 copy [options] -S stream [-P parent] [-F] [-r] [toFile[rev] ...]
#
# options: -c changelist# -f -n -v -m max -q
function _p4_copy()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__)"
            return ;;
        -b)
            __p4_complete__ "$(__p4_branches__)"
            return ;;
        -S)
            __p4_complete__ "$(__p4_streams__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-c -f -n -v -m -q -b -r -s -S -P -F -r"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# counter -- Display, set, or delete a counter
#
# p4 counter name
# p4 counter [-f] name value
# p4 counter [-f] -d name
# p4 counter [-f] -i name
# p4 counter [-f] -m [ pair list ]
function _p4_counter()
{
    case "$cur" in
        -*)
            __p4_complete__ "-f -d -i -m"
            ;;
        *)
            __p4_complete__ "$(__p4_counters__)"
            ;;
    esac
}


# counters -- Display list of known counters
#
# p4 counters [-e nameFilter -m max]
function _p4_counters()
{
    __p4_complete__ "-e -m"
}

# cstat -- Dump change/sync status for current client
#
# p4 cstat [files...]
function _p4_cstat()
{
    __p4_filenames__
}

# delete -- Open an existing file for deletion from the depot
#
# p4 delete [-c changelist#] [-n -v -k] file ...
function _p4_delete()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-c -n -k -v"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# depot -- Create or edit a depot specification
#
# p4 depot [-t type] name
# p4 depot -d [-f] name
# p4 depot -o name
# p4 depot -i
function _p4_depot()
{
    case "$prev" in
        -t)
            __p4_complete__ ""
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-t -d -f -o -i"
            ;;
        *)
            __p4_complete__ "$(__p4_depots__)"
            ;;
    esac
}

# depots -- Lists defined depots
#
# p4 depots
function _p4_depots()
{
    __p4_complete__ ""
}

# describe -- Display a changelist description
#
# p4 describe [-d<flags> -m -s -S -f -O -I] changelist# ...
function _p4_describe()
{
    case "$cur" in
        -*)
            __p4_complete__ "-d -m -s -S -f -O -I"
            ;;
        *)
            __p4_complete__ "$(__p4_changes__)"
            ;;
    esac
}

# diff -- Display diff of client file with depot file
#
# p4 diff [-d<flags> -f -m max -Od -s<flag> -t] [file[rev] ...]
function _p4_diff()
{
    case "$cur" in
        -*)
            __p4_complete__ "-d -f -m -Od -s -t"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# diff2 -- Compare one set of depot files to another
#
# p4 diff2 [options] fromFile[rev] toFile[rev]
# p4 diff2 [options] -b branch [[fromFile[rev]] toFile[rev]]
# p4 diff2 [options] [-S stream] [-P parent] [[fromFile[rev]] toFile[rev]]
#
# options: -d<flags> -Od -q -t -u
function _p4_diff2()
{
    case "$prev" in
        -b)
            __p4_complete__ "$(__p4_branches__)"
            return ;;
        -S)
            __p4_complete__ "$(__p4_streams__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-d -Od -q -t -u -b -S -P"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# dirs -- List depot subdirectories
#
# p4 dirs [-C -D -H] [-S stream] dir[revRange] ...
function _p4_dirs()
{
    case "$prev" in
        -S)
            __p4_complete__ "$(__p4_streams__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-C -D -H -S"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# edit -- Open an existing file for edit
#
# p4 edit [-c changelist#] [-k -n] [-t filetype] file ...
function _p4_edit()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
        -t)
            __p4_complete__ "$__p4_filetypes"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-c -k -n -t"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# filelog -- List revision history of files
#
# p4 filelog [-c changelist# -h -i -l -L -t -m max -p -s] file[revRange] ...
function _p4_filelog()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-c -h -i -l -L -t -m -p -s"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# files -- List files in the depot
#
# p4 files [ -a ] [ -A ] [ -e ] [ -m max ] file[revRange] ...
# p4 files -U unloadfile ...
function _p4_files()
{
    case "$cur" in
        -*)
            __p4_complete__ "-a -A -e -m -U"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# fix -- Mark jobs as being fixed by the specified changelist
#
# p4 fix [-d] [-s status] -c changelist# jobName ...
function _p4_fix()
{
    case "$prev" in
        -s)
            __p4_complete__ "$__p4_change_status"
            return ;;
        -c)
            __p4_complete__ "$(__p4_changes__ submitted)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-d -s -c"
            ;;
        *)
            __p4_complete__ "$(__p4_jobs__)"
            ;;
    esac
}

# fixes -- List jobs with fixes and the changelists that fix them
#
# p4 fixes [-i -m max -c changelist# -j jobName] [file[revRange] ...]
function _p4_fixes()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ submitted)"
            return ;;
        -j)
            __p4_complete__ "$(__p4_jobs__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-i -m -c -j"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# flush -- synonym for 'sync -k'
function _p4_flush()
{
    case "$cur" in
        -*)
            __p4_complete__ "-f -L -n -N -q -r -m"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# fstat -- Dump file info
#
# p4 fstat [-F filter -L -T fields -m max -r] [-c | -e changelist#]
# [-Ox -Rx -Sx] [-A pattern] [-U] file[rev] ...
function _p4_fstat()
{
    case "$prev" in
        -c|-e)
            __p4_complete__ "$(__p4_changes__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-F -L -T -m -r -c -e -O -R -S -A -U"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# grep -- Print lines matching a pattern
#
# p4 grep [options] -e pattern file[revRange]...
#
# options: -a -i -n -A <num> -B <num> -C <num> -t -s (-v|-l|-L) (-F|-G)
function _p4_grep()
{
    case "$cur" in
        -*)
            __p4_complete__ "-a -i -n -A -B -C -t -s -v -l -L -F -G -e"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# group -- Change members of user group
#
# p4 group [-a|-A] name
# p4 group -d [-a] name
# p4 group -o name
# p4 group -i [-a|-A]
function _p4_group()
{
    case "$cur" in
        -*)
            __p4_complete__ "-a -A -d -o -i"
            ;;
        *)
            __p4_complete__ "$(__p4_groups__)"
            ;;
    esac
}

# groups -- List groups (of users)
#
# p4 groups [-m max] [-v] [group]
# p4 groups [-m max] [-i [-v]] user | group
# p4 groups [-m max] [-g | -u | -o] name
function _p4_groups()
{
    case "$prev" in
        -i)
            __p4_complete__ "$(__p4_users__) $(__p4_groups__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-m -v -i -g -u -o"
            ;;
        *)
            __p4_complete__ "$(__p4_groups__)"
            ;;
    esac
}

# have -- List the revisions most recently synced to the current workspace
#
# p4 have [file ...]
function _p4_have()
{
    __p4_filenames__
}

# help -- Print help message
#
# p4 help [command ...]
function _p4_help()
{
    __p4_complete__ "$__p4_help_keywords $__p4_cmds"
}

# info -- Display client/server information
#
# p4 info [-s]
function _p4_info()
{
    __p4_complete__ "-s"
}

# integrate -- Integrate one set of files into another
#
# p4 integrate [options] fromFile[revRange] toFile
# p4 integrate [options] -b branch [-r] [toFile[revRange] ...]
# p4 integrate [options] -b branch -s fromFile[revRange] [toFile ...]
# p4 integrate [options] -S stream [-r] [-P parent] [file[revRange] ...]
#
# options: -c changelist# -Di -f -h -O<flags> -n -m max -R<flags> -q -v
function _p4_integrate()
{
    case "$prev" in
        -b)
            __p4_complete__ "$(__p4_branches__)"
            return ;;
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
        -S)
            __p4_complete__ "$(__p4_streams__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-c -Di -f -h -O -n -m -R -q -v -b -r -s -S -P"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# integrated -- List integrations that have been submitted
#
# p4 integrated [-r] [-b branch] [file ...]
function _p4_integrated()
{
    case "$prev" in
        -b)
            __p4_complete__ "$(__p4_branches__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-r -b"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# interchanges -- Report changes not yet integrated
#
# p4 interchanges [options] fromFile[revRange] toFile
# p4 interchanges [options] -b branch [toFile[revRange] ...]
# p4 interchanges [options] -b branch -s fromFile[revRange] [toFile ...]
# p4 interchanges [options] -S stream [-P parent] [file[revRange] ...]
#
# options: -f -l -r -t -u -F
function _p4_interchanges()
{
    case "$prev" in
        -b)
            __p4_complete__ "$(__p4_branches__)"
            return ;;
        -S)
            __p4_complete__ "$(__p4_streams__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-f -l -r -t -u -F -b -s -S -P"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# istat -- Show/cache a stream's integration status
#
# p4 istat [ -a -c -r -s ] stream
function _p4_istat()
{
    case "$cur" in
        -*)
            __p4_complete__ "-a -c -r -s"
            ;;
        *)
            __p4_complete__ "$(__p4_streams__)"
            ;;
    esac
}

# job -- Create or edit a job (defect) specification
#
# p4 job [-f] [jobName]
# p4 job -d jobName
# p4 job -o [jobName]
# p4 job -i [-f]
function _p4_job()
{
    case "$cur" in
        -*)
            __p4_complete__ "-f -d -o -i"
            ;;
        *)
            __p4_complete__ "$(__p4_jobs__)"
            ;;
    esac
}

# jobs -- Display list of jobs
#
# p4 jobs [-e jobview -i -l -m max -r] [file[revRange] ...]
# p4 jobs -R
function _p4_jobs()
{
    case "$cur" in
        -*)
            __p4_complete__ "-e -i -l -m -r -R"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# key -- Display, set, or delete a key/value pair
#
# p4 key name
# p4 key name value
# p4 key [-d] name
# p4 key [-i] name
# p4 key [-m] [ pair list ]
function _p4_key()
{
    case "$cur" in
        -*)
            __p4_complete__ "-d -i -m"
            ;;
        *)
            __p4_complete__ "$(__p4_keys__)"
            ;;
    esac
}

# keys -- Display list of known key/values
#
# p4 keys [-e nameFilter -m max]
function _p4_keys()
{
    __p4_complete__ "-e -m"
}

# label -- Create or edit a label specification
#
# p4 label [-f -g -t template] name
# p4 label -d [-f -g] name
# p4 label -o [-t template] name
# p4 label -i [-f -g]
function _p4_label()
{
    case "$cur" in
        -*)
            __p4_complete__ "-f -g -t -d -o -i"
            ;;
        *)
            __p4_complete__ "$(__p4_labels__)"
            ;;
    esac
}

# labels -- Display list of defined labels
#
# p4 labels [-t] [-u user] [[-e|-E] nameFilter -m max] [file[revrange]]
# p4 labels [-t] [-u user] [[-e|-E] nameFilter -m max] [-a|-s serverID]
# p4 labels -U
function _p4_labels()
{
    case "$prev" in
        -u)
            __p4_complete__ "$(__p4_users__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-t -u -e -E -m -a -s -U"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# labelsync -- Apply the label to the contents of the client workspace
#
# p4 labelsync [-a -d -g -n -q] -l label [file[revRange] ...]
function _p4_labelsync()
{
    case "$prev" in
        -l)
            __p4_complete__ "$(__p4_labels__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-a -d -g -n -q -l"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# list -- Create a temporary list of files that can be used as a label
#
# p4 list [ -l label ] [ -C ] [ -M ] file[revRange] ...
# p4 list -l label -d [ -M ]
function _p4_list()
{
    case "$prev" in
        -l)
            __p4_complete__ "$(__p4_labels__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-l -C -M -d"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# lock -- Lock an open file to prevent it from being submitted
#
# p4 lock [-c changelist#] [file ...]
# p4 lock -g -c changelist#
function _p4_lock()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-c -g"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# logger -- Report changed jobs and changelists
#
# p4 logger [-c sequence#] [-t counter]
function _p4_logger()
{
    __p4_complete__ "-c -t"
}

# login -- Log in to Perforce by obtaining a session ticket
#
# p4 login [-a -p] [-r <remotespec>] [-h <host>] [user]
# p4 login [-s] [-r <remotespec>]
function _p4_login()
{
    case "$cur" in
        -*)
            __p4_complete__ "-a -p -r -h -s -r"
            ;;
        *)
            __p4_complete__ "$(__p4_users__)"
            ;;
    esac
}

# logout -- Log out from Perforce by removing or invalidating a ticket.
#
# p4 logout [-a] [user]
function _p4_logout()
{
    case "$cur" in
        -*)
            __p4_complete__ "-a"
            ;;
        *)
            __p4_complete__ "$(__p4_users__)"
            ;;
    esac
}

# merge -- Merge one set of files into another 
#
# p4 merge [options] [-F] [--from stream] [toFile][revRange]
# p4 merge [options] fromFile[revRange] toFile
#
# options: -c changelist# -m max -n -Ob -q
function _p4_merge()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-c -m -n -Ob -q -F --from"
            ;;
        --*)
            __p4_complete__ "--from"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# move -- move file(s) from one location to another
# rename -- synonym for 'move'
#
# p4 move [-c changelist#] [-f -n -k] [-t filetype] fromFile toFile
function _p4_move()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
        -t)
            __p4_complete__ "$__p4_filetypes"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-c -f -n -k -t"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# opened -- List open files and display file status
#
# p4 opened [-a -c changelist# -C client -u user -m max -s -g] [file ...]
# p4 opened [-a -x -m max ] [file ...]
function _p4_opened()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
        -C)
            __p4_complete__ "$(__p4_clients__)"
            return ;;
        -u)
            __p4_complete__ "$(__p4_users__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-a -c -C -u -m -s -g -x"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# passwd -- Set the user's password on the server (and Windows client)
#
# p4 passwd [-O oldPassword -P newPassword] [user]
function _p4_passwd()
{
    case "$cur" in
        -*)
            __p4_complete__ "-O -P"
            ;;
        *)
            __p4_complete__ "$(__p4_users__)"
            ;;
    esac
}

# populate -- Branch a set of files as a one-step operation
#
# p4 populate [options] fromFile[rev] toFile
# p4 populate [options] -b branch [-r] [toFile[rev]]
# p4 populate [options] -b branch -s fromFile[rev] [toFile]
# p4 populate [options] -S stream [-P parent] [-r] [toFile[rev]]
#
# options: -d description -f -m max -n -o
function _p4_populate()
{
    case "$prev" in
        -b)
            __p4_complete__ "$(__p4_branches__)"
            return ;;
        -S)
            __p4_complete__ "$(__p4_streams__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-d -f -m -n -o -b -r -s -S -P"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# print -- Write a depot file to standard output
#
# p4 print [-a -A -k -o localFile -q -m max] file[revRange] ...
# p4 print -U unloadfile ...
function _p4_print()
{
    case "$cur" in
        -*)
            __p4_complete__ "-a -A -k -o -q -m -U"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# protect -- Modify protections in the server namespace
#
# p4 protect
# p4 protect -o
# p4 protect -i
function _p4_protect()
{
    __p4_complete__ "-o -i"
}

# protects -- Display protections defined for a specified user and path
#
# p4 protects [-a | -g group | -u user] [-h host] [-m] [file ...]
function _p4_protects()
{
    case "$prev" in
        -g)
            __p4_complete__ "$(__p4_groups__)"
            return ;;
        -u)
            __p4_complete__ "$(__p4_users__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-a -g -u -h -m"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# prune -- Remove unmodified branched files from a stream
#
# p4 prune [-y] -S stream
function _p4_prune()
{
    case "$prev" in
        -S)
            __p4_complete__ "$(__p4_streams__)"
            return ;;
    esac

    __p4_complete__ "-y -S"
}

# reconcile -- Open files for add, delete, and/or edit to reconcile
#              client with workspace changes made outside of Perforce
#
# rec         -- synonym for 'reconcile'
# status      -- 'reconcile -n + opened' (output uses local paths)
# status -A   -- synonym for 'reconcile -ead' (output uses local paths)
#
# clean       -- synonym for 'reconcile -w'
#
# p4 reconcile [-c change#] [-e -a -d -f -I -l -m -n -w] [file ...]
# p4 status [-c change#] [-A | [-e -a -d] | [-s]] [-f -I -m] [file ...]
# p4 clean [-e -a -d -I -l -n] [file ...]
# p4 reconcile -k [-l -n] [file ...]
# p4 status -k [file ...]
function _p4_reconcile()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-c -e -a -d -f -I -l -m -n -w"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# reopen -- Change the filetype of an open file or move it to another changelist
#
# p4 reopen [-c changelist#] [-t filetype] file ...
function _p4_reopen()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
        -t)
            __p4_complete__ "$__p4_filetypes"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-c -t"
            ;;
        *)
            __p4_filenames__
    esac
}

# resolve -- Resolve integrations and updates to workspace files
#
# p4 resolve [options] [file ...]
#
# options: -A<flags> -a<flags> -d<flags> -f -n -N -o -t -v -c changelist#
function _p4_resolve()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-A -a -d -f -n -N -o -t -v -c"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# resolved -- Show files that have been resolved but not submitted
#
# p4 resolved [-o] [file ...]
function _p4_resolved()
{
    case "$cur" in
        -*)
            __p4_complete__ "-o"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# revert -- Discard changes from an opened file
#
# p4 revert [-a -n -k -w -c changelist# -C client] file ...
function _p4_revert()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
        -C)
            __p4_complete__ "$(__p4_clients__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-a -n -k -w -c -C"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# review -- List and track changelists (for the review daemon)
#
# p4 review [-c changelist#] [-t counter]
function _p4_review()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
    esac

    __p4_complete__ "-c -t"
}

# reviews -- List the users who are subscribed to review files
#
# p4 reviews [-C client] [-c changelist#] [file ...]
function _p4_reviews()
{
    case "$prev" in
        -C)
            __p4_complete__ "$(__p4_clients__)"
            return ;;
        -c)
            __p4_complete__ "$(__p4_changes__ submitted)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-C -c"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# set -- Set or display Perforce variables
#
# p4 set [-q] [-s -S service] [var=[value]]
function _p4_set()
{
    case "$cur" in
        -*)
            __p4_complete__ "-q -s -S"
            ;;
        *)
            __p4_complete__ "$(__p4_vars__)"
            ;;
    esac
}

# shelve -- Store files from a pending changelist into the depot
#
# p4 shelve [-Af] [-p] [files]
# p4 shelve [-Af] [-a option] [-p] -i [-f | -r]
# p4 shelve [-Af] [-a option] [-p] -r -c changelist#
# p4 shelve [-Af] [-a option] [-p] -c changelist# [-f] [file ...]
# p4 shelve [-As] -d -c changelist# [-f] [file ...]
function _p4_shelve()
{
    case "$prev" in
        -a)
            __p4_complete__ "$__p4_submitopts"
            return ;;
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-Af -p -a -i -f -r -c -As -d -c"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# status    -- 'reconcile -n + opened' (output uses local paths)
# status -A -- synonym for 'reconcile -ead' (output uses local paths)
#
# p4 status [-c change#] [-A | [-e -a -d] | [-s]] [-f -I -m] [file ...]
function _p4_status()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-c -A -e -a -d -s -f -I -m"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# sizes -- Display information about the size of the files in the depot
#
# p4 sizes [-a -S] [-s | -z] [-b size] [-h|-H] [-m max] file[revRange] ...
# p4 sizes -A [-a] [-s] [-b size] [-h|-H] [-m max] archivefile...
# p4 sizes -U unloadfile ...
function _p4_sizes()
{
    case "$cur" in
        -*)
            __p4_complete__ "-a -S -s -z -b -h -H -m -A -U"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# stream -- Create, delete, or modify a stream specification
#
# p4 stream [-f] [-d] [-P parent] [-t type] [name]
# p4 stream [-o [-v]] [-P parent] [-t type] [name[@change]]
# p4 stream [-f] [-d] name
# p4 stream -i [-f]
# p4 stream edit
# p4 stream resolve [-a<flag>] [-n] [-o]
# p4 stream revert
function _p4_stream()
{
    case "$prev" in
        -t)
            __p4_complete__ "$(__p4_streamtypes)"
            return ;;
        resolve)
            __p4_complete__ "-a -n -o"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-f -d -P -t -o -v -i edit resolve revert"
            ;;
        *)
            __p4_complete__ "$(__p4_streams__)"
            ;;
    esac
}

# streams -- Display list of streams
#
# p4 streams [-U -F filter -T fields -m max] [streamPath ...]
function _p4_streams()
{
    __p4_complete__ "-U -F -T -m"
}

# submit -- Submit open files to the depot
#
# p4 submit [-Af -r -s -f option --noretransfer 0|1]
# p4 submit [-Af -r -s -f option] file
# p4 submit [-Af -r -f option] -d description
# p4 submit [-Af -r -f option] -d description file
# p4 submit [-Af -r -f option --noretransfer 0|1] -c changelist#
# p4 submit -e shelvedChange#
# p4 submit -i [-Af -r -s -f option]
function _p4_submit()
{
    case "$prev" in
        -f)
            __p4_complete__ "$__p4_submitopts"
            return ;;
        --noretransfer)
            __p4_complete__ "0 1"
            return ;;
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
        -e)
            __p4_complete__ "$(__p4_changes__ shelved)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-Af -r -s -f --noretransfer -d -c -e -i"
            ;;
        --*)
            __p4_complete__ "--noretransfer"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# sync -- Synchronize the client with its view of the depot
# flush -- synonym for 'sync -k'
# update -- synonym for 'sync -s'
#
# p4 sync [-f -L -n -N -k -q -r] [-m max] [file[revRange] ...]
# p4 sync [-L -n -N -q -s] [-m max] [file[revRange] ...]
# p4 sync [-L -n -N -p -q] [-m max] [file[revRange] ...]
function _p4_sync()
{
    case "$cur" in
        -*)
            __p4_complete__ "-f -L -n -N -k -q -r -m -s -p"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# tag -- Tag files with a label
#
# p4 tag [-d -g -n -U] -l label file[revRange] ...
function _p4_tag()
{
    case "$prev" in
        -l)
            __p4_complete__ "$(__p4_labels__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-d -g -n -U -l"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# unlock -- Release a locked file, leaving it open
#
# p4 unlock [-c | -s changelist# | -x] [-f] [file ...]
# p4 -c client unlock [-f] -r
function _p4_unlock()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
        -s)
            __p4_complete__ "$(__p4_changes__ shelved)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-c -s -x -f -r"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# unshelve -- Restore shelved files from a pending change into a workspace
#
# p4 unshelve -s changelist# [options] [file ...]
# Options: [-A<f|s> -f -n] [-c changelist#]
#          [-b branch|-S stream [-P parent]]
function _p4_unshelve()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
        -b)
            __p4_complete__ "$(__p4_branches__)"
            return ;;
        -S)
            __p4_complete__ "$(__p4_streams__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-Af -As -f -n -c -b -S -P"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# update -- synonym for 'sync -s'
function _p4_update()
{
    case "$cur" in
        -*)
            __p4_complete__ "-L -n -N -q -m"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

# user -- Create or edit a user specification
#
# p4 user [-f] [name]
# p4 user -d [-f] name
# p4 user -o [name]
# p4 user -i [-f]
function _p4_user()
{
    case "$cur" in
        -*)
            __p4_complete__ "-f -d -o -i"
            ;;
        *)
            __p4_complete__ "$(__p4_users__)"
            ;;
    esac
}

# users -- List Perforce users
#
# p4 users [-l -a -r -c] [-m max] [user ...]
function _p4_users()
{
    case "$cur" in
        -*)
            __p4_complete__ "-l -a -r -c -m"
            ;;
        *)
            __p4_complete__ "$(__p4_users__)"
            ;;
    esac
}

# where -- Show how file names are mapped by the client view
#
# p4 where [file ...]
function _p4_where()
{
    __p4_filenames__
}

function __find_p4_cmd__()
{
    for word in ${COMP_WORDS[@]:1}; do
        if [ ${word:0:1} != "-" ]; then
            for p4cmd in ${__p4_cmds}; do
                if [ "$word" == "$p4cmd" ]; then
                    echo $p4cmd
                    return
                fi
            done
        fi
    done
}

function __p4_global_opts__()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_clients__)"
            return ;;
        -u)
            __p4_complete__ "$(__p4_users__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "$__p4_g_opts"
            ;;
        *)
            __p4_complete__ "$__p4_cmds"
            ;;
    esac
}

function _p4()
{
    prev=${COMP_WORDS[COMP_CWORD-1]}
    cur=${COMP_WORDS[COMP_CWORD]}

    local cmd=$(__find_p4_cmd__)
    if [ -z "$cmd" ]; then
        __p4_global_opts__
    elif [ "$cur" == "$cmd" ]; then
        __p4_complete__ "$__p4_cmds"
    else
        case "$cmd" in
            add)
                _p4_add
                ;;
            annotate)
                _p4_annotate
                ;;
            attribute)
                _p4_attribute
                ;;
            branch)
                _p4_branch
                ;;
            branches)
                _p4_branches
                ;;
            change)
                _p4_change
                ;;
            changelist)
                _p4_change
                ;;
            changes)
                _p4_changes
                ;;
            changelists)
                _p4_changes
                ;;
            clean)
                _p4_clean
                ;;
            client)
                _p4_client
                ;;
            clients)
                _p4_clients
                ;;
            copy)
                _p4_copy
                ;;
            counter)
                _p4_counter
                ;;
            counters)
                _p4_counters
                ;;
            cstat)
                _p4_cstat
                ;;
            delete)
                _p4_delete
                ;;
            depot)
                _p4_depot
                ;;
            depots)
                _p4_depots
                ;;
            describe)
                _p4_describe
                ;;
            diff)
                _p4_diff
                ;;
            diff2)
                _p4_diff2
                ;;
            dirs)
                _p4_dirs
                ;;
            edit)
                _p4_edit
                ;;
            filelog)
                _p4_filelog
                ;;
            files)
                _p4_files
                ;;
            fix)
                _p4_fix
                ;;
            fixes)
                _p4_fixes
                ;;
            flush)
                _p4_flush
                ;;
            fstat)
                _p4_fstat
                ;;
            grep)
                _p4_grep
                ;;
            group)
                _p4_group
                ;;
            groups)
                _p4_groups
                ;;
            have)
                _p4_have
                ;;
            help)
                _p4_help
                ;;
            info)
                _p4_info
                ;;
            integrate)
                _p4_integrate
                ;;
            integrated)
                _p4_integrated
                ;;
            interchanges)
                _p4_interchanges
                ;;
            istat)
                _p4_istat
                ;;
            job)
                _p4_job
                ;;
            jobs)
                _p4_jobs
                ;;
            key)
                _p4_key
                ;;
            keys)
                _p4_keys
                ;;
            label)
                _p4_label
                ;;
            labels)
                _p4_labels
                ;;
            labelsync)
                _p4_labelsync
                ;;
            list)
                _p4_list
                ;;
            lock)
                _p4_lock
                ;;
            logger)
                _p4_logger
                ;;
            login)
                _p4_login
                ;;
            logout)
                _p4_logout
                ;;
            merge)
                _p4_merge
                ;;
            move)
                _p4_move
                ;;
            opened)
                _p4_opened
                ;;
            passwd)
                _p4_passwd
                ;;
            populate)
                _p4_populate
                ;;
            print)
                _p4_print
                ;;
            protect)
                _p4_protect
                ;;
            protects)
                _p4_protects
                ;;
            prune)
                _p4_prune
                ;;
            reconcile|rec)
                _p4_reconcile
                ;;
            rename)
                _p4_move
                ;;
            reopen)
                _p4_reopen
                ;;
            resolve)
                _p4_resolve
                ;;
            resolved)
                _p4_resolved
                ;;
            revert)
                _p4_revert
                ;;
            review)
                _p4_review
                ;;
            reviews)
                _p4_reviews
                ;;
            set)
                _p4_set
                ;;
            shelve)
                _p4_shelve
                ;;
            status)
                _p4_status
                ;;
            sizes)
                _p4_sizes
                ;;
            stream)
                _p4_stream
                ;;
            streams)
                _p4_streams
                ;;
            submit)
                _p4_submit
                ;;
            sync)
                _p4_sync
                ;;
            tag)
                _p4_tag
                ;;
            tickets)
                _p4_tickets
                ;;
            unlock)
                _p4_unlock
                ;;
            unshelve)
                _p4_unshelve
                ;;
            update)
                _p4_update
                ;;
            user)
                _p4_user
                ;;
            users)
                _p4_users
                ;;
            where)
                _p4_where
                ;;
            workspace)
                _p4_client
                ;;
            workspaces)
                _p4_clients
                ;;
            *)
                __p4_complete__ "$__p4_cmds"
                ;;
        esac
    fi
}

complete -o filenames -o bashdefault -F _p4 p4
