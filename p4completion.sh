#!/bin/bash

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

function __p4_commands__()
{
    __p4_complete__ "$__p4_cmds"
}

function __p4_client__()
{
    echo $(p4 info | awk '/Client name/ {print $3}')
}

function __p4_changes__()
{
    local client=$(__p4_client__)
    echo $(p4 changes -c $client -u $USER -s pending | awk '{print $2}')
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

# Below are mappings to Perforce commands
function _p4_add()
{
    case "$prev" in
        -c)
            __p4_complete__ "$(__p4_changes__)"
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
            __p4_complete__ "$(__p4_changes__)"
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
            __p4_complete__ "$(__p4_changes__)"
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
            __p4_complete__ "$(__p4_changes__)"
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
            __p4_complete__ "$(__p4_changes__)"
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
            __p4_complete__ "$(__p4_changes__)"
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
            __p4_complete__ "$(__p4_changes__)"
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
            __p4_complete__ "$(__p4_changes__)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete__ "-d -s -c"
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
        esac
    fi
}

complete -o filenames -o bashdefault -F _p4 p4
