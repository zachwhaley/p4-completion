# A bash completion script for Perforce
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

__p4_cmds="add annotate attribute branch branches change changes changelist changelists client clients copy
    counter counters cstat delete depot depots describe diff diff2 dirs edit filelog files fix fixes flush fstat grep
    group groups have help info integrate integrated interchanges istat job jobs key keys label labels labelsync list
    lock logger login logout merge move open opened passwd populate print protect protects reconcile rename reopen
    resolve resolved revert review reviews set shelve status sizes stream streams submit sync tag tickets unlock
    unshelve update user users where workspace workspaces"

__p4_types="text binary symlink apple resource unicode utf16"

__p4_help_keywords="simple commands charset environment filetypes jobview revisions usage views"

function __p4_commands__()
{
    __p4_complete__ "$__p4_cmds"
}

function __p4_client__()
{
    echo $(p4 info | awk '/Client name/ {print $3}')
}

# Takes one argument
# 1: Status of the changes
function __p4_changes__()
{
    local client=$(__p4_client__)
    echo $(p4 changes -c $client -u $USER -s $1 | awk '{print $2}')
}

function __p4_users__()
{
   echo $(p4 users | awk '{print $1}')
}

function __p4_clients__()
{
    echo $(p4 clients -u $HOME | awk '{print $2}')
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
    echo $(p4 labels | awk '{print $2}')
}

function __p4_workspaces__()
{
    echo $(p4 workspaces | awk '{print $2}')
}

# Below are mappings to Perforce commands
function _p4_add()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return
            ;;
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

function _p4_annotate()
{
    case "$cur" in
        -*)
            __p4_complete__ "-a -c -i -I -d -t -d"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

function _p4_archive()
{
    case "$cur" in
        -*)
            __p4_complete__ "-n -h -p -q -t -D"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

function _p4_attribute()
{
    case "$cur" in
        -*)
            __p4_complete__ "-e -f -p -n -v -i"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

function _p4_branch()
{
    __p4_complete__ "-f -S -P -o -d -f -i"
}

function _p4_branches()
{
    case "$prev" in
        -u)
            __p4_complete__ "$(__p4_users__)"
            return
            ;;
    esac

    __p4_complete__ "-t -u -e -m"
}

function _p4_cachepurge()
{
    case "$cur" in
        -*)
            __p4_complete__ "-a -f -m -s -i -n -R -s -O -D"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

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
            __p4_complete__ "-S -f -u -O -d -s -o -i -t -U"
            ;;
        *)
            __p4_complete__ "$(__p4_changes__ pending)"
    esac
}

function _p4_changes()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_clients__)"
            return ;;
        -s)
            __p4_complete__ "pending submitted shelved"
            return ;;
        -u)
            __p4_complete__ "$(__p4_users__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-i -t -l -L -f -c -m -s -u"
            ;;
        *)
            __p4_filenames__
    esac
}

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

function _p4_client()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-f -t -o -d -Fs -S -s -i -c"
            ;;
        *)
            __p4_complete__ "$(__p4_clients__)"
            ;;
    esac
}

function _p4_clients()
{
    case "$prev" in
        -u)
            __p4_complete__ "$(__p4_users__)"
            return ;;
    esac

    __p4_complete__ "-t -u -e -m -S -U"
}

function _p4_configure()
{
    __p4_complete__ "set unset show"
}

function _p4_copy()
{
    case "$prev" in
        -b)
            __p4_complete__ "$(__p4_branches__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-b -r -s -S -P -F"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

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

function _p4_counters()
{
    __p4_complete__ "-e -m"
}

function _p4_cstat()
{
    __p4_filenames__
}

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

function _p4_depot()
{
    case "$cur" in
        -*)
            __p4_complete__ "-f -d -i -o"
            ;;
        *)
            __p4_complete__ "$(__p4_depots__)"
            ;;
    esac
}

function _p4_describe()
{
    case "$cur" in
        -*)
            __p4_complete__ "-s -S -f -O"
            ;;
        *)
            __p4_complete__ "$(__p4_changes__ pending)"
            ;;
    esac
}

function _p4_diff()
{
    case "$cur" in
        -*)
            __p4_complete__ "-d -f -m -Od -sb -sd -se -sr -sl -t"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

function _p4_diff2()
{
    case "$prev" in
        -b)
            __p4_complete__ "$(__p4_branches__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-d -f -m -Od -q -t -u -b -S -P"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

function _p4_edit()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
        -t)
            __p4_complete__ "$__p4_types"
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

function _p4_filelog()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-c -i -l -L -t -m -p -s"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

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

function _p4_fix()
{
    case "$prev" in
        -s)
            __p4_complete__ "pending submitted closed"
            return ;;
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-d -s -c"
            ;;
    esac
}

function _p4_fixes()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-i -m -j -c"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

function _p4_flush()
{
    case "$cur" in
        -*)
            __p4_complete__ "-f -L -n -q"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

function _p4_grep()
{
    case "$cur" in
        -*)
            __p4_complete__ "-e"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

function _p4_group()
{
    case "$cur" in
        -*)
            __p4_complete__ "-a -d -o -i"
            ;;
        *)
            __p4_complete__ "$(__p4_groups__)"
            ;;
    esac
}

function _p4_groups()
{
    case "$prev" in
        -u)
            __p4_complete__ "$(__p4_users__)"
            return ;;
        -o)
            __p4_complete__ "$(__p4_users__)"
            return ;;
        -i)
            __p4_complete__ "$(__p4_users__) $(__p4_groups__)"
            return ;;
        -g)
            __p4_complete__ "$(__p4_groups__)"
            return ;;
        -v)
            __p4_complete__ "$(__p4_groups__)"
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

function _p4_have()
{
    __p4_filenames__
}

function _p4_help()
{
    __p4_complete__ "$__p4_help_keywords $__p4_cmds"
}

function _p4_info()
{
    __p4_complete__ "-s"
}

function _p4_integrate()
{
    case "$prev" in
        -b)
            __p4_complete__ "$(__p4_branches__)"
            return ;;
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-b -S -s -P -Di -f -h -O -n -m -R -q -v"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

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

function _p4_interchanges()
{
    case "$prev" in
        -b)
            __p4_complete__ "$(__p4_branches__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-b -s -S -f -l -r -t"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

function _p4_job()
{
    __p4_complete__ "-f -d -o -i"
}

function _p4_jobs()
{
    case "$cur" in
        -*)
            __p4_complete__ "-e -i -l -r -m -R"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

function _p4_jobspec()
{
    __p4_complete__ "-i -o"
}

function _p4_label()
{
    case "$cur" in
        -*)
            __p4_complete__ "-f -d -g -t -o"
            ;;
        *)
            __p4_complete__ "$(__p4_labels__)"
            ;;
    esac
}

function _p4_labels()
{
    case "$prev" in
        -u)
            __p4_complete__ "$(__p4_users__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-t -u -e -m  -U -a -s"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

function _p4_labelsync()
{
    case "$prev" in
        -l)
            __p4_complete__ "$(__p4_labels__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-a -d -g -l -n -q"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

function _p4_list()
{
    case "$prev" in
        -l)
            __p4_complete__ "$(__p4_labels__)"
            return ;;
        -d)
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

function _p4_lock()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-c"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

function _p4_lockstat()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_clients__)"
            return ;;
    esac

    __p4_complete__ "-c -C"
}

function _p4_login()
{
    __p4_complete__ "-a -h -p -s"
}

function _p4_logout()
{
    case "$prev" in
        -a)
            __p4_complete__ "$(__p4_users__)"
            return ;;
    esac

    __p4_complete__ "-a"
}

function _p4_merge()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
        -b)
            __p4_complete__ "$(__p4_branches__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-c -n -m -q -b -r -s -S -P -F -Ob"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

function _p4_move()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
        -t)
            __p4_changes__ pending "$__p4_types"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-c -t -f -k -n"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

function _p4_opened()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
        -C)
            __p4_complete__ "$(__p4_workspaces__)"
            return ;;
        -u)
            __p4_complete__ "$(__p4_users__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-a -c -C -u -m -s -x"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

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

function _p4_rename()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
        -t)
            __p4_complete__ "$__p4_types"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-c -f -k -n -t"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

function _p4_reopen()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
        -t)
            __p4_complete__ "$__p4_types"
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

function _p4_resolve()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-am -af -as -at -ay -Aa -Ab -Ac -Ad -At -Am -db -dw -dl -f -n -N -o -t -v -c"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

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

function _p4_revert()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-a -n -k -w -c"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

function _p4_review()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
    esac

    __p4_complete__ "-c -t"
}

function _p4_shelve()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-f -i -a -c -d -r -p"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

function _p4_submit()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
        -e)
            __p4_complete__ "$(__p4_changes__ shelved)"
            return ;;
        -f)
            __p4_complete__ "submitunchanged submitunchanged+reopen revertunchanged revertunchanged+reopen
                leaveunchanged leaveunchanged+reopen"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-c -e -d -f -i -r -s"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

function _p4_sync()
{
    case "$cur" in
        -*)
            __p4_complete__ "-f -k -L -m -n -N -p -q -s --parallel"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

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
            __p4_complete__ "-c -s -x -f"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

function _p4_unshelve()
{
    case "$prev" in
        -s)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
        -c)
            __p4_complete__ "$(__p4_changes__ pending)"
            return ;;
        -b)
            __p4_complete__ "$(__p4_branches__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-s -c -b -S -f -n"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

function _p4_update()
{
    case "$cur" in
        -*)
            __p4_complete__ "-L -n -q"
            ;;
        *)
            __p4_filenames__
            ;;
    esac
}

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

function _p4()
{
    prev=${COMP_WORDS[COMP_CWORD-1]}
    cur=${COMP_WORDS[COMP_CWORD]}

    if [ ${COMP_CWORD} -eq 1 ]; then
        __p4_commands__
    else
        local cmd=${COMP_WORDS[1]}
        case "$cmd" in
            add)
                _p4_add
                ;;
            annotate)
                _p4_annotate
                ;;
            archive)
                _p4_archive
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
            cachepurge)
                _p4_cachepurge
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
            configure)
                _p4_configure
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
            describe)
                _p4_describe
                ;;
            diff)
                _p4_diff
                ;;
            diff2)
                _p4_diff2
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
            flush)
                _p4_flush
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
            job)
                _p4_job
                ;;
            jobs)
                _p4_jobs
                ;;
            jobspec)
                _p4_jobspec
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
            lockstat)
                _p4_lockstat
                ;;
            login)
                _p4_login
                ;;
            merge)
                _p4_merge
                ;;
            move)
                _p4_move
                ;;
            open)
                _p4_edit
                ;;
            print)
                _p4_print
                ;;
            rename)
                _p4_rename
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
            shelve)
                _p4_shelve
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
        esac
    fi
}

complete -o filenames -o bashdefault -F _p4 p4
