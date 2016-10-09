# A bash completion script for Perforce 2015.2
# Author: Zach Whaley, zachbwhaley@gmail.com

# Turn on extended globbing and programmable completion
shopt -s extglob progcomp

# If bash-completion is not installed, use the functionality from bash-completion 1.3
# Copied from https://github.com/scop/bash-completion/blob/7c81ef895455d0f7543c65789ff62808e7465578/bash_completion
if ! type _init_completion &>/dev/null; then
#
#   bash_completion - programmable completion functions for bash 3.2+
#
#   Copyright © 2006-2008, Ian Macdonald <ian@caliban.org>
#             © 2009-2011, Bash Completion Maintainers
#                     <bash-completion-devel@lists.alioth.debian.org>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2, or (at your option)
#   any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software Foundation,
#   Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#
#   The latest version of this software can be obtained here:
#
#   http://bash-completion.alioth.debian.org/
#
#   RELEASE: 1.3


# Assign variable one scope above the caller
# Usage: local "$1" && _upvar $1 "value(s)"
# Param: $1  Variable name to assign value to
# Param: $*  Value(s) to assign.  If multiple values, an array is
#            assigned, otherwise a single value is assigned.
# NOTE: For assigning multiple variables, use '_upvars'.  Do NOT
#       use multiple '_upvar' calls, since one '_upvar' call might
#       reassign a variable to be used by another '_upvar' call.
# See: http://fvue.nl/wiki/Bash:_Passing_variables_by_reference
_upvar() {
    if unset -v "$1"; then           # Unset & validate varname
        if (( $# == 2 )); then
            eval $1=\"\$2\"          # Return single value
        else
            eval $1=\(\"\${@:2}\"\)  # Return array
        fi
    fi
}


# Assign variables one scope above the caller
# Usage: local varname [varname ...] && 
#        _upvars [-v varname value] | [-aN varname [value ...]] ...
# Available OPTIONS:
#     -aN  Assign next N values to varname as array
#     -v   Assign single value to varname
# Return: 1 if error occurs
# See: http://fvue.nl/wiki/Bash:_Passing_variables_by_reference
_upvars() {
    if ! (( $# )); then
        echo "${FUNCNAME[0]}: usage: ${FUNCNAME[0]} [-v varname"\
            "value] | [-aN varname [value ...]] ..." 1>&2
        return 2
    fi
    while (( $# )); do
        case $1 in
            -a*)
                # Error checking
                [[ ${1#-a} ]] || { echo "bash: ${FUNCNAME[0]}: \`$1': missing"\
                    "number specifier" 1>&2; return 1; }
                printf %d "${1#-a}" &> /dev/null || { echo "bash:"\
                    "${FUNCNAME[0]}: \`$1': invalid number specifier" 1>&2
                    return 1; }
                # Assign array of -aN elements
                [[ "$2" ]] && unset -v "$2" && eval $2=\(\"\${@:3:${1#-a}}\"\) && 
                shift $((${1#-a} + 2)) || { echo "bash: ${FUNCNAME[0]}:"\
                    "\`$1${2+ }$2': missing argument(s)" 1>&2; return 1; }
                ;;
            -v)
                # Assign single value
                [[ "$2" ]] && unset -v "$2" && eval $2=\"\$3\" &&
                shift 3 || { echo "bash: ${FUNCNAME[0]}: $1: missing"\
                "argument(s)" 1>&2; return 1; }
                ;;
            *)
                echo "bash: ${FUNCNAME[0]}: $1: invalid option" 1>&2
                return 1 ;;
        esac
    done
}


# Reassemble command line words, excluding specified characters from the
# list of word completion separators (COMP_WORDBREAKS).
# @param $1 chars  Characters out of $COMP_WORDBREAKS which should
#     NOT be considered word breaks. This is useful for things like scp where
#     we want to return host:path and not only path, so we would pass the
#     colon (:) as $1 here.
# @param $2 words  Name of variable to return words to
# @param $3 cword  Name of variable to return cword to
#
__reassemble_comp_words_by_ref() {
    local exclude i j ref
    # Exclude word separator characters?
    if [[ $1 ]]; then
        # Yes, exclude word separator characters;
        # Exclude only those characters, which were really included
        exclude="${1//[^$COMP_WORDBREAKS]}"
    fi
        
    # Default to cword unchanged
    eval $3=$COMP_CWORD
    # Are characters excluded which were former included?
    if [[ $exclude ]]; then
        # Yes, list of word completion separators has shrunk;
        # Re-assemble words to complete
        for (( i=0, j=0; i < ${#COMP_WORDS[@]}; i++, j++)); do
            # Is current word not word 0 (the command itself) and is word not
            # empty and is word made up of just word separator characters to be
            # excluded?
            while [[ $i -gt 0 && ${COMP_WORDS[$i]} && 
                ${COMP_WORDS[$i]//[^$exclude]} == ${COMP_WORDS[$i]} 
            ]]; do
                [ $j -ge 2 ] && ((j--))
                # Append word separator to current word
                ref="$2[$j]"
                eval $2[$j]=\${!ref}\${COMP_WORDS[i]}
                # Indicate new cword
                [ $i = $COMP_CWORD ] && eval $3=$j
                # Indicate next word if available, else end *both* while and for loop
                (( $i < ${#COMP_WORDS[@]} - 1)) && ((i++)) || break 2
            done
            # Append word to current word
            ref="$2[$j]"
            eval $2[$j]=\${!ref}\${COMP_WORDS[i]}
            # Indicate new cword
            [[ $i == $COMP_CWORD ]] && eval $3=$j
        done
    else
        # No, list of word completions separators hasn't changed;
        eval $2=\( \"\${COMP_WORDS[@]}\" \)
    fi
} # __reassemble_comp_words_by_ref()


# @param $1 exclude  Characters out of $COMP_WORDBREAKS which should NOT be
#     considered word breaks. This is useful for things like scp where
#     we want to return host:path and not only path, so we would pass the
#     colon (:) as $1 in this case.  Bash-3 doesn't do word splitting, so this
#     ensures we get the same word on both bash-3 and bash-4.
# @param $2 words  Name of variable to return words to
# @param $3 cword  Name of variable to return cword to
# @param $4 cur  Name of variable to return current word to complete to
# @see ___get_cword_at_cursor_by_ref()
__get_cword_at_cursor_by_ref() {
    local cword words=()
    __reassemble_comp_words_by_ref "$1" words cword

    local i cur2
    local cur="$COMP_LINE"
    local index="$COMP_POINT"
    for (( i = 0; i <= cword; ++i )); do
        while [[
            # Current word fits in $cur?
            "${#cur}" -ge ${#words[i]} &&
            # $cur doesn't match cword?
            "${cur:0:${#words[i]}}" != "${words[i]}"
        ]]; do
            # Strip first character
            cur="${cur:1}"
            # Decrease cursor position
            ((index--))
        done

        # Does found word matches cword?
        if [[ "$i" -lt "$cword" ]]; then
            # No, cword lies further;
            local old_size="${#cur}"
            cur="${cur#${words[i]}}"
            local new_size="${#cur}"
            index=$(( index - old_size + new_size ))
        fi
    done

    if [[ "${words[cword]:0:${#cur}}" != "$cur" ]]; then
        # We messed up. At least return the whole word so things keep working
        cur2=${words[cword]}
    else
        cur2=${cur:0:$index}
    fi

    local "$2" "$3" "$4" && 
        _upvars -a${#words[@]} $2 "${words[@]}" -v $3 "$cword" -v $4 "$cur2"
}


# Get the word to complete and optional previous words.
# This is nicer than ${COMP_WORDS[$COMP_CWORD]}, since it handles cases
# where the user is completing in the middle of a word.
# (For example, if the line is "ls foobar",
# and the cursor is here -------->   ^
# Also one is able to cross over possible wordbreak characters.
# Usage: _get_comp_words_by_ref [OPTIONS] [VARNAMES]
# Available VARNAMES:
#     cur         Return cur via $cur
#     prev        Return prev via $prev
#     words       Return words via $words
#     cword       Return cword via $cword
#
# Available OPTIONS:
#     -n EXCLUDE  Characters out of $COMP_WORDBREAKS which should NOT be 
#                 considered word breaks. This is useful for things like scp
#                 where we want to return host:path and not only path, so we
#                 would pass the colon (:) as -n option in this case.  Bash-3
#                 doesn't do word splitting, so this ensures we get the same
#                 word on both bash-3 and bash-4.
#     -c VARNAME  Return cur via $VARNAME
#     -p VARNAME  Return prev via $VARNAME
#     -w VARNAME  Return words via $VARNAME
#     -i VARNAME  Return cword via $VARNAME
#
# Example usage:
#
#    $ _get_comp_words_by_ref -n : cur prev
#
_get_comp_words_by_ref()
{
    local exclude flag i OPTIND=1
    local cur cword words=()
    local upargs=() upvars=() vcur vcword vprev vwords

    while getopts "c:i:n:p:w:" flag "$@"; do
        case $flag in
            c) vcur=$OPTARG ;;
            i) vcword=$OPTARG ;;
            n) exclude=$OPTARG ;;
            p) vprev=$OPTARG ;;
            w) vwords=$OPTARG ;;
        esac
    done
    while [[ $# -ge $OPTIND ]]; do 
        case ${!OPTIND} in
            cur)   vcur=cur ;;
            prev)  vprev=prev ;;
            cword) vcword=cword ;;
            words) vwords=words ;;
            *) echo "bash: $FUNCNAME(): \`${!OPTIND}': unknown argument" \
                1>&2; return 1
        esac
        let "OPTIND += 1"
    done

    __get_cword_at_cursor_by_ref "$exclude" words cword cur

    [[ $vcur   ]] && { upvars+=("$vcur"  ); upargs+=(-v $vcur   "$cur"  ); }
    [[ $vcword ]] && { upvars+=("$vcword"); upargs+=(-v $vcword "$cword"); }
    [[ $vprev  ]] && { upvars+=("$vprev" ); upargs+=(-v $vprev 
        "${words[cword - 1]}"); }
    [[ $vwords ]] && { upvars+=("$vwords"); upargs+=(-a${#words[@]} $vwords
        "${words[@]}"); }

    (( ${#upvars[@]} )) && local "${upvars[@]}" && _upvars "${upargs[@]}"
}

_init_completion()
{
    _get_comp_words_by_ref $@
}
fi # Bash Completion Check

# Generate completion reply
# Accepts 1 to 4 arguments:
# 1. Space separated string of possible completion words
# 2. A prefix to be added to each possible completion word
# 3. Generate possible completion matches for this word
# 4. A suffix to be added to each possible completion word. Can be used to prevent completing a single result
__p4_complete() {
    local IFS=$' \t\n' cur_="${3-$cur}"

    [[ $cur_ == *:* ]] && cur_="${cur#*:}"
    COMPREPLY=( $(compgen -P "${2-}" -W "$1" -S "${4-}" -- "$cur_") )
}

__p4_filenames() {
    COMPREPLY=( $(compgen -f ${cur}) )
}

__p4_directories() {
    COMPREPLY=( $(compgen -d ${cur}) )
}

# Generate completion reply for files with revisions.
# e.g. file@label or file#revision
__p4_compfilerev() {
    type compopt &>/dev/null && compopt -o nospace
    local file prefix cur_="$cur"

    case "$cur_" in
        *\#*)
            file="${cur_%%#*}"
            prefix="$file#"
            cur_="${cur_#*#}"
            __p4_complete "$(__p4_filelog_revs "$file") have head none" "$prefix" "$cur_"
            ;;
        *@*)
            if ! shopt -q hostcomplete; then
                # Disable file@label completion if the user has enabled hostcomplete.
                # hostcomplete is disabled by default for those that have bash-completion installed,
                # but for those that don't, hostcomplete will do weird things if we try to
                # complete words with an @ symbol.
                # To disable hostcomplete, run `shopt -u hostcomplete`
                prefix="${cur_%%?(\\)@*}@"
                cur_="${cur_#*@}"
                __p4_complete "$(__p4_labels "$cur_") now" "$prefix" "$cur_"
            fi
            ;;
        *)
            local files=( $(compgen -f "$cur_") )
            if [ ${#files[@]} -eq 1 ]; then
                if ! shopt -q hostcomplete; then
                    # Only suggest @ and # as a completion if the user has disabled hostcomplete.
                    __p4_complete "# @" "$files" ""
                fi
            fi
            ;;
    esac
}

# Generate completion reply for flagged options, like -d which can add more than one flag to an
# option, e.g. p4 diff -dub
# 1. Space separated string of possible completion flags
# 2. A prefix of the existing flags to be added to each possible completion word (e.g. -dub)
__p4_compflags() {
    __p4_complete "${1//[${2-$cur}]/}" "${2-$cur}" ""
}

__p4_g_opts="-b -c -C -d -H -I -G -L -p -P -q -r -s -Q -u -x -z"

__p4_cmds="add annotate attribute branch branches change changes changelist changelists clean client clients copy counter counters cstat delete depot depots describe diff diff2 dirs edit filelog files fix fixes flush fstat grep group groups have help info integrate integrated interchanges istat job jobs key keys label labels labelsync list lock logger login logout merge move opened passwd populate print protect protects prune rec reconcile rename reopen resolve resolved revert review reviews set shelve status sizes stream streams submit sync tag tickets unlock unshelve update user users where workspace workspaces"

__p4_filetypes="text binary symlink apple resource unicode utf8 utf16"

__p4_streamtypes="mainline virtual development release task"

__p4_submitopts="submitunchanged submitunchanged+reopen revertunchanged revertunchanged+reopen leaveunchanged leaveunchanged+reopen"

__p4_change_status="pending shelved submitted"

__p4_charsets="auto none eucjp iso8859-1 iso8859-5 iso8859-7 iso8859-15 macosroman shiftjis koi8-r utf8 utf8-bom utf16 and utf16-nobom without utf16le utf16le-bom utf16be utf16be-bom utf32 and utf32-nobom without utf32le utf32le-bom utf32be utf32be-bom cp850 cp858 cp936 cp949 cp950 cp1251 winansi cp1253"

__p4_help_keywords="simple commands charset environment filetypes jobview revisions usage views"

# Takes one argument
# 1: The Perforce environment variable to return
__p4_var() {
    echo $(command p4 set $1 | awk '{split($1,a,"="); print a[2]}')
}

__p4_vars() {
    echo $(command p4 set | awk -F'=' '{print $1}')
}

__p4_find_cmd() {
    for word in ${words[@]:1}; do
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

# Takes one argument
# 1: option to look for
__p4_find_val() {
    local cmd=$(__p4_find_cmd)
    local opts=0
    for i in ${!words[@]}; do
        if [[ "$opts" -eq 1 ]]; then
            if [ "${words[$i]}" == "$1" ]; then
                echo "${words[(($i+1))]}"
                return
            fi
        elif [ "${words[$i]}" == "$cmd" ]; then
            opts=1
        fi
    done
}

# Takes one argument
# 1: Status of the changes
__p4_changes() {
    local changes="command p4 changes -m 10 "

    [ -n "$1" ] && changes="$changes -s $1 "
    [ -n "$p4client" ] && changes="$changes -c $p4client "
    [ -n "$p4user" ] && changes="$changes -u $p4user "
    echo $($changes | awk '{print $2}')
}

__p4_mychanges() {
    local client=$(__p4_var P4CLIENT)
    local user=$(__p4_var P4USER)
    local changes="command p4 changes -m 10 "

    [ -n "$1" ] && changes="$changes -s $1 "
    echo $($changes -c $client -u $user | awk '{print $2}')
}

__p4_filelog_revs() {
    local revs=$(command p4 filelog -m 10 $1 | awk '/^... #[0-9]/ {print $2}')
    echo "${revs//\#/}"
}

__p4_users() {
   echo $(command p4 users | awk '{print $1}')
}

__p4_clients() {
    local clients="command p4 clients -m 10 "

    [ -n "${1-$cur}" ] && clients="$clients -e ${1-$cur}* "
    [ -n "$p4user" ] && clients="$clients -u $p4user "
    [ -n "$p4stream" ] && clients="$clients -S $p4stream "
    echo $($clients | awk '{print $2}')
}

__p4_branches() {
    local branches="command p4 branches -m 10 "

    [ -n "${1-$cur}" ] && branches="$branches -e ${1-$cur}* "
    [ -n "$p4user" ] && branches="$branches -u $p4user "
    echo $($branches | awk '{print $2}')
}

__p4_counters() {
    echo $(command p4 counters -m 10 | awk '{print $1}')
}

__p4_depots() {
    echo $(command p4 depots | awk '{print $2}')
}

__p4_groups() {
    echo $(command p4 groups | awk '{print $2}')
}

__p4_labels() {
    local labels="command p4 labels -m 10 "

    [ -n "${1-$cur}" ] && labels="$labels -e ${1-$cur}* "
    [ -n "$p4user" ] && labels="$labels -u $p4user "
    echo $($labels | awk '{print $2}')
}

__p4_streams() {
    echo $(command p4 streams -m 10 | awk '{print $1}')
}

__p4_jobs() {
    echo $(command p4 jobs -m 10 | awk '{print $1}')
}

__p4_keys() {
    echo $(command p4 keys -m 10 | awk '{print $1}')
}

## Below are mappings to Perforce commands

# add -- Open a new file to add it to the depot
#
# p4 add [-c changelist#] [-d -f -I -n] [-t filetype] file ...
_p4_add() {
    case "$prev" in
        -c)
            __p4_complete "$(__p4_mychanges pending)"
            return ;;
        -t)
            __p4_complete "$__p4_filetypes"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-c -d -f -I -n -t"
            ;;
        *)
            __p4_filenames
            ;;
    esac
}

# annotate -- Print file lines and their revisions
#
# p4 annotate [-aciIqtu -d<flags>] file[revRange] ...
_p4_annotate() {
    case "$cur" in
        -d*)
            __p4_compflags "b w l"
            ;;
        -*)
            __p4_complete "-a -c -i -I -q -t -d"
            ;;
        *)
            __p4_compfilerev
            ;;
    esac
}

# attribute -- Set per-revision attributes on revisions
#
# p4 attribute [-e -f -p] -n name [-v value] files...
# p4 attribute [-e -f -p] -i -n name file
_p4_attribute() {
    case "$cur" in
        -*)
            __p4_complete "-e -f -p -i -n -v"
            ;;
        *)
            __p4_filenames
            ;;
    esac
}

# branch -- Create, modify, or delete a branch view specification
#
# p4 branch [-f] name
# p4 branch -d [-f] name
# p4 branch [ -S stream ] [ -P parent ] -o name
# p4 branch -i [-f]
_p4_branch() {
    case "$prev" in
        -S)
            __p4_complete "$(__p4_streams)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-f -d -S -P -o -i"
            ;;
        *)
            __p4_complete "$(__p4_branches)"
            ;;
    esac
}

# branches -- Display list of branch specifications
#
# p4 branches [-t] [-u user] [[-e|-E] nameFilter -m max]
_p4_branches() {
    p4user=$(__p4_find_val "-u")
    case "$prev" in
        -u)
            __p4_complete "$(__p4_users)"
            return ;;
    esac

    __p4_complete "-t -u -e -E -m"
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
_p4_change() {
    case "$prev" in
        -t)
            __p4_complete "restricted public"
            return ;;
        -U)
            __p4_complete "$(__p4_users)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-s -f -u -O -I -d -o -i -t -U"
            ;;
        *)
            __p4_complete "$(__p4_changes)"
    esac
}
_p4_changelist() {
    _p4_change
}

# changes -- Display list of pending and submitted changelists
# changelists -- synonym for 'changes'
#
# p4 changes [-i -t -l -L -f] [-c client] [ -e changelist# ]
#     [-m max] [-s status] [-u user] [file[revRange] ...]
_p4_changes() {
    p4client=$(__p4_find_val "-c")
    p4user=$(__p4_find_val "-u")
    p4chstat=$(__p4_find_val "-s")
    case "$prev" in
        -c)
            __p4_complete "$(__p4_clients)"
            return ;;
        -e)
            __p4_complete "$(__p4_changes $p4chstat)"
            return ;;
        -s)
            __p4_complete "$__p4_change_status"
            return ;;
        -u)
            __p4_complete "$(__p4_users)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-i -t -l -L -f -c -e -m -s -u"
            ;;
        *)
            __p4_compfilerev
    esac
}
_p4_changelists() {
    _p4_changes
}

# clean -- synonym for 'reconcile -w'
#
# p4 clean [-e -a -d -I -l -n] [file ...]
_p4_clean() {
    case "$cur" in
        -*)
            __p4_complete "-e -a -d -I -l -n"
            ;;
        *)
            __p4_filenames
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
_p4_client() {
    p4stream=$(__p4_find_val "-S")
    case "$prev" in
        -t)
            __p4_complete "$(__p4_clients)"
            return ;;
        -c)
            __p4_complete "$(__p4_changes)"
            return ;;
        -S)
            __p4_complete "$(__p4_streams)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-f -t -d -Fs -o -S -c -s -i"
            ;;
        *)
            __p4_complete "$(__p4_clients)"
            ;;
    esac
}
_p4_workspace() {
    _p4_client
}

# clients -- Display list of clients
# workspaces -- synonym for 'clients'
#
# p4 clients [-t] [-u user] [[-e|-E] nameFilter -m max] [-S stream]
#            [-a | -s serverID]
# p4 clients -U
_p4_clients() {
    case "$prev" in
        -u)
            __p4_complete "$(__p4_users)"
            return ;;
        -S)
            __p4_complete "$(__p4_streams)"
            return ;;
    esac

    __p4_complete "-t -u -e -E -m -S -a -s -U"
}
_p4_workspaces() {
    _p4_clients
}

# copy -- Copy one set of files to another
#
# p4 copy [options] fromFile[rev] toFile
# p4 copy [options] -b branch [-r] [toFile[rev] ...]
# p4 copy [options] -b branch -s fromFile[rev] [toFile ...]
# p4 copy [options] -S stream [-P parent] [-F] [-r] [toFile[rev] ...]
#
# options: -c changelist# -f -n -v -m max -q
_p4_copy() {
    p4stream=$(__p4_find_val "-S")
    case "$prev" in
        -c)
            __p4_complete "$(__p4_changes)"
            return ;;
        -b)
            __p4_complete "$(__p4_branches)"
            return ;;
        -S)
            __p4_complete "$(__p4_streams)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-c -f -n -v -m -q -b -r -s -S -P -F -r"
            ;;
        *)
            __p4_compfilerev
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
_p4_counter() {
    case "$cur" in
        -*)
            __p4_complete "-f -d -i -m"
            ;;
        *)
            __p4_complete "$(__p4_counters)"
            ;;
    esac
}


# counters -- Display list of known counters
#
# p4 counters [-e nameFilter -m max]
_p4_counters() {
    __p4_complete "-e -m"
}

# cstat -- Dump change/sync status for current client
#
# p4 cstat [files...]
_p4_cstat() {
    __p4_filenames
}

# delete -- Open an existing file for deletion from the depot
#
# p4 delete [-c changelist#] [-n -v -k] file ...
_p4_delete() {
    case "$prev" in
        -c)
            __p4_complete "$(__p4_mychanges pending)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-c -n -k -v"
            ;;
        *)
            __p4_filenames
            ;;
    esac
}

# depot -- Create or edit a depot specification
#
# p4 depot [-t type] name
# p4 depot -d [-f] name
# p4 depot -o name
# p4 depot -i
_p4_depot() {
    case "$prev" in
        -t)
            __p4_complete "local remote spec stream unload archive tangent"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-t -d -f -o -i"
            ;;
        *)
            __p4_complete "$(__p4_depots)"
            ;;
    esac
}

# depots -- Lists defined depots
#
# p4 depots
_p4_depots() {
    type compopt &>/dev/null && compopt +o default
}

# describe -- Display a changelist description
#
# p4 describe [-d<flags> -m -s -S -f -O -I] changelist# ...
_p4_describe() {
    case "$cur" in
        -d*)
            __p4_compflags "n c s u b w l"
            ;;
        -*)
            __p4_complete "-d -m -s -S -f -O -I"
            ;;
        *)
            __p4_complete "$(__p4_changes)"
            ;;
    esac
}

# diff -- Display diff of client file with depot file
#
# p4 diff [-d<flags> -f -m max -Od -s<flag> -t] [file[rev] ...]
_p4_diff() {
    case "$cur" in
        -d*)
            __p4_compflags "n c s u b w l"
            ;;
        -s*)
            __p4_compflags "a b d e l r"
            ;;
        -*)
            __p4_complete "-d -f -m -Od -s -t"
            ;;
        *)
            __p4_compfilerev
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
_p4_diff2() {
    case "$prev" in
        -d*)
            __p4_compflags "n c s u b w l"
            ;;
        -b)
            __p4_complete "$(__p4_branches)"
            return ;;
        -S)
            __p4_complete "$(__p4_streams)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-d -Od -q -t -u -b -S -P"
            ;;
        *)
            __p4_compfilerev
            ;;
    esac
}

# dirs -- List depot subdirectories
#
# p4 dirs [-C -D -H] [-S stream] dir[revRange] ...
_p4_dirs() {
    case "$prev" in
        -S)
            __p4_complete "$(__p4_streams)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-C -D -H -S"
            ;;
        *)
            __p4_compfilerev
            ;;
    esac
}

# edit -- Open an existing file for edit
#
# p4 edit [-c changelist#] [-k -n] [-t filetype] file ...
_p4_edit() {
    case "$prev" in
        -c)
            __p4_complete "$(__p4_mychanges pending)"
            return ;;
        -t)
            __p4_complete "$__p4_filetypes"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-c -k -n -t"
            ;;
        *)
            __p4_filenames
            ;;
    esac
}

# filelog -- List revision history of files
#
# p4 filelog [-c changelist# -h -i -l -L -t -m max -p -s] file[revRange] ...
_p4_filelog() {
    case "$prev" in
        -c)
            __p4_complete "$(__p4_changes)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-c -h -i -l -L -t -m -p -s"
            ;;
        *)
            __p4_compfilerev
            ;;
    esac
}

# files -- List files in the depot
#
# p4 files [ -a ] [ -A ] [ -e ] [ -m max ] file[revRange] ...
# p4 files -U unloadfile ...
_p4_files() {
    case "$cur" in
        -*)
            __p4_complete "-a -A -e -m -U"
            ;;
        *)
            __p4_compfilerev
            ;;
    esac
}

# fix -- Mark jobs as being fixed by the specified changelist
#
# p4 fix [-d] [-s status] -c changelist# jobName ...
_p4_fix() {
    p4chstat=$(__p4_find_val "-s")
    case "$prev" in
        -s)
            __p4_complete "$__p4_change_status"
            return ;;
        -c)
            __p4_complete "$(__p4_changes)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-d -s -c"
            ;;
        *)
            __p4_complete "$(__p4_jobs)"
            ;;
    esac
}

# fixes -- List jobs with fixes and the changelists that fix them
#
# p4 fixes [-i -m max -c changelist# -j jobName] [file[revRange] ...]
_p4_fixes() {
    case "$prev" in
        -c)
            __p4_complete "$(__p4_changes)"
            return ;;
        -j)
            __p4_complete "$(__p4_jobs)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-i -m -c -j"
            ;;
        *)
            __p4_compfilerev
            ;;
    esac
}

# flush -- synonym for 'sync -k'
_p4_flush() {
    case "$cur" in
        -*)
            __p4_complete "-f -L -n -N -q -r -m"
            ;;
        *)
            __p4_filenames
            ;;
    esac
}

# fstat -- Dump file info
#
# p4 fstat [-F filter -L -T fields -m max -r] [-c | -e changelist#]
# [-Ox -Rx -Sx] [-A pattern] [-U] file[rev] ...
_p4_fstat() {
    case "$prev" in
        -c|-e)
            __p4_complete "$(__p4_changes)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-F -L -T -m -r -c -e -O -R -S -A -U"
            ;;
        *)
            __p4_compfilerev
            ;;
    esac
}

# grep -- Print lines matching a pattern
#
# p4 grep [options] -e pattern file[revRange]...
#
# options: -a -i -n -A <num> -B <num> -C <num> -t -s (-v|-l|-L) (-F|-G)
_p4_grep() {
    case "$cur" in
        -*)
            __p4_complete "-a -i -n -A -B -C -t -s -v -l -L -F -G -e"
            ;;
        *)
            __p4_compfilerev
            ;;
    esac
}

# group -- Change members of user group
#
# p4 group [-a|-A] name
# p4 group -d [-a] name
# p4 group -o name
# p4 group -i [-a|-A]
_p4_group() {
    case "$cur" in
        -*)
            __p4_complete "-a -A -d -o -i"
            ;;
        *)
            __p4_complete "$(__p4_groups)"
            ;;
    esac
}

# groups -- List groups (of users)
#
# p4 groups [-m max] [-v] [group]
# p4 groups [-m max] [-i [-v]] user | group
# p4 groups [-m max] [-g | -u | -o] name
_p4_groups() {
    case "$prev" in
        -i)
            __p4_complete "$(__p4_users) $(__p4_groups)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-m -v -i -g -u -o"
            ;;
        *)
            __p4_complete "$(__p4_groups)"
            ;;
    esac
}

# have -- List the revisions most recently synced to the current workspace
#
# p4 have [file ...]
_p4_have() {
    __p4_filenames
}

# help -- Print help message
#
# p4 help [command ...]
_p4_help() {
    __p4_complete "$__p4_help_keywords $__p4_cmds"
}

# info -- Display client/server information
#
# p4 info [-s]
_p4_info() {
    __p4_complete "-s"
}

# integrate -- Integrate one set of files into another
#
# p4 integrate [options] fromFile[revRange] toFile
# p4 integrate [options] -b branch [-r] [toFile[revRange] ...]
# p4 integrate [options] -b branch -s fromFile[revRange] [toFile ...]
# p4 integrate [options] -S stream [-r] [-P parent] [file[revRange] ...]
#
# options: -c changelist# -Di -f -h -O<flags> -n -m max -R<flags> -q -v
_p4_integrate() {
    case "$prev" in
        -O*)
            __p4_compflags "b r"
            ;;
        -R*)
            __p4_compflags "b d s"
            ;;
        -b)
            __p4_complete "$(__p4_branches)"
            return ;;
        -c)
            __p4_complete "$(__p4_changes)"
            return ;;
        -S)
            __p4_complete "$(__p4_streams)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-c -Di -f -h -O -n -m -R -q -v -b -r -s -S -P"
            ;;
        *)
            __p4_compfilerev
            ;;
    esac
}

# integrated -- List integrations that have been submitted
#
# p4 integrated [-r] [-b branch] [file ...]
_p4_integrated() {
    case "$prev" in
        -b)
            __p4_complete "$(__p4_branches)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-r -b"
            ;;
        *)
            __p4_filenames
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
_p4_interchanges() {
    case "$prev" in
        -b)
            __p4_complete "$(__p4_branches)"
            return ;;
        -S)
            __p4_complete "$(__p4_streams)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-f -l -r -t -u -F -b -s -S -P"
            ;;
        *)
            __p4_compfilerev
            ;;
    esac
}

# istat -- Show/cache a stream's integration status
#
# p4 istat [ -a -c -r -s ] stream
_p4_istat() {
    case "$cur" in
        -*)
            __p4_complete "-a -c -r -s"
            ;;
        *)
            __p4_complete "$(__p4_streams)"
            ;;
    esac
}

# job -- Create or edit a job (defect) specification
#
# p4 job [-f] [jobName]
# p4 job -d jobName
# p4 job -o [jobName]
# p4 job -i [-f]
_p4_job() {
    case "$cur" in
        -*)
            __p4_complete "-f -d -o -i"
            ;;
        *)
            __p4_complete "$(__p4_jobs)"
            ;;
    esac
}

# jobs -- Display list of jobs
#
# p4 jobs [-e jobview -i -l -m max -r] [file[revRange] ...]
# p4 jobs -R
_p4_jobs() {
    case "$cur" in
        -*)
            __p4_complete "-e -i -l -m -r -R"
            ;;
        *)
            __p4_compfilerev
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
_p4_key() {
    case "$cur" in
        -*)
            __p4_complete "-d -i -m"
            ;;
        *)
            __p4_complete "$(__p4_keys)"
            ;;
    esac
}

# keys -- Display list of known key/values
#
# p4 keys [-e nameFilter -m max]
_p4_keys() {
    __p4_complete "-e -m"
}

# label -- Create or edit a label specification
#
# p4 label [-f -g -t template] name
# p4 label -d [-f -g] name
# p4 label -o [-t template] name
# p4 label -i [-f -g]
_p4_label() {
    case "$cur" in
        -*)
            __p4_complete "-f -g -t -d -o -i"
            ;;
        *)
            __p4_complete "$(__p4_labels)"
            ;;
    esac
}

# labels -- Display list of defined labels
#
# p4 labels [-t] [-u user] [[-e|-E] nameFilter -m max] [file[revrange]]
# p4 labels [-t] [-u user] [[-e|-E] nameFilter -m max] [-a|-s serverID]
# p4 labels -U
_p4_labels() {
    case "$prev" in
        -u)
            __p4_complete "$(__p4_users)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-t -u -e -E -m -a -s -U"
            ;;
        *)
            __p4_compfilerev
            ;;
    esac
}

# labelsync -- Apply the label to the contents of the client workspace
#
# p4 labelsync [-a -d -g -n -q] -l label [file[revRange] ...]
_p4_labelsync() {
    case "$prev" in
        -l)
            __p4_complete "$(__p4_labels)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-a -d -g -n -q -l"
            ;;
        *)
            __p4_compfilerev
            ;;
    esac
}

# list -- Create a temporary list of files that can be used as a label
#
# p4 list [ -l label ] [ -C ] [ -M ] file[revRange] ...
# p4 list -l label -d [ -M ]
_p4_list() {
    case "$prev" in
        -l)
            __p4_complete "$(__p4_labels)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-l -C -M -d"
            ;;
        *)
            __p4_compfilerev
            ;;
    esac
}

# lock -- Lock an open file to prevent it from being submitted
#
# p4 lock [-c changelist#] [file ...]
# p4 lock -g -c changelist#
_p4_lock() {
    case "$prev" in
        -c)
            __p4_complete "$(__p4_mychanges)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-c -g"
            ;;
        *)
            __p4_filenames
            ;;
    esac
}

# logger -- Report changed jobs and changelists
#
# p4 logger [-c sequence#] [-t counter]
_p4_logger() {
    __p4_complete "-c -t"
}

# login -- Log in to Perforce by obtaining a session ticket
#
# p4 login [-a -p] [-r <remotespec>] [-h <host>] [user]
# p4 login [-s] [-r <remotespec>]
_p4_login() {
    case "$cur" in
        -*)
            __p4_complete "-a -p -r -h -s -r"
            ;;
        *)
            __p4_complete "$(__p4_users)"
            ;;
    esac
}

# logout -- Log out from Perforce by removing or invalidating a ticket.
#
# p4 logout [-a] [user]
_p4_logout() {
    case "$cur" in
        -*)
            __p4_complete "-a"
            ;;
        *)
            __p4_complete "$(__p4_users)"
            ;;
    esac
}

# merge -- Merge one set of files into another 
#
# p4 merge [options] [-F] [--from stream] [toFile][revRange]
# p4 merge [options] fromFile[revRange] toFile
#
# options: -c changelist# -m max -n -Ob -q
_p4_merge() {
    case "$prev" in
        -c)
            __p4_complete "$(__p4_changes)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-c -m -n -Ob -q -F --from"
            ;;
        --*)
            __p4_complete "--from"
            ;;
        *)
            __p4_compfilerev
            ;;
    esac
}

# move -- move file(s) from one location to another
# rename -- synonym for 'move'
#
# p4 move [-c changelist#] [-f -n -k] [-t filetype] fromFile toFile
_p4_move() {
    case "$prev" in
        -c)
            __p4_complete "$(__p4_mychanges pending)"
            return ;;
        -t)
            __p4_complete "$__p4_filetypes"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-c -f -n -k -t"
            ;;
        *)
            __p4_filenames
            ;;
    esac
}
_p4_rename() {
    _p4_move
}

# opened -- List open files and display file status
#
# p4 opened [-a -c changelist# -C client -u user -m max -s -g] [file ...]
# p4 opened [-a -x -m max ] [file ...]
_p4_opened() {
    p4client=$(__p4_find_val "-C")
    p4user=$(__p4_find_val "-u")
    case "$prev" in
        -c)
            __p4_complete "$(__p4_changes pending)"
            return ;;
        -C)
            __p4_complete "$(__p4_clients)"
            return ;;
        -u)
            __p4_complete "$(__p4_users)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-a -c -C -u -m -s -g -x"
            ;;
        *)
            __p4_filenames
            ;;
    esac
}

# passwd -- Set the user's password on the server (and Windows client)
#
# p4 passwd [-O oldPassword -P newPassword] [user]
_p4_passwd() {
    case "$cur" in
        -*)
            __p4_complete "-O -P"
            ;;
        *)
            __p4_complete "$(__p4_users)"
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
_p4_populate() {
    case "$prev" in
        -b)
            __p4_complete "$(__p4_branches)"
            return ;;
        -S)
            __p4_complete "$(__p4_streams)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-d -f -m -n -o -b -r -s -S -P"
            ;;
        *)
            __p4_compfilerev
            ;;
    esac
}

# print -- Write a depot file to standard output
#
# p4 print [-a -A -k -o localFile -q -m max] file[revRange] ...
# p4 print -U unloadfile ...
_p4_print() {
    case "$cur" in
        -*)
            __p4_complete "-a -A -k -o -q -m -U"
            ;;
        *)
            __p4_compfilerev
            ;;
    esac
}

# protect -- Modify protections in the server namespace
#
# p4 protect
# p4 protect -o
# p4 protect -i
_p4_protect() {
    __p4_complete "-o -i"
}

# protects -- Display protections defined for a specified user and path
#
# p4 protects [-a | -g group | -u user] [-h host] [-m] [file ...]
_p4_protects() {
    case "$prev" in
        -g)
            __p4_complete "$(__p4_groups)"
            return ;;
        -u)
            __p4_complete "$(__p4_users)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-a -g -u -h -m"
            ;;
        *)
            __p4_filenames
            ;;
    esac
}

# prune -- Remove unmodified branched files from a stream
#
# p4 prune [-y] -S stream
_p4_prune() {
    case "$prev" in
        -S)
            __p4_complete "$(__p4_streams)"
            return ;;
    esac

    __p4_complete "-y -S"
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
_p4_reconcile() {
    case "$prev" in
        -c)
            __p4_complete "$(__p4_mychanges pending)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-c -e -a -d -f -I -l -m -n -w"
            ;;
        *)
            __p4_filenames
            ;;
    esac
}
_p4_rec() {
    _p4_reconcile
}

# reopen -- Change the filetype of an open file or move it to another changelist
#
# p4 reopen [-c changelist#] [-t filetype] file ...
_p4_reopen() {
    case "$prev" in
        -c)
            __p4_complete "$(__p4_mychanges pending)"
            return ;;
        -t)
            __p4_complete "$__p4_filetypes"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-c -t"
            ;;
        *)
            __p4_filenames
    esac
}

# resolve -- Resolve integrations and updates to workspace files
#
# p4 resolve [options] [file ...]
#
# options: -A<flags> -a<flags> -d<flags> -f -n -N -o -t -v -c changelist#
_p4_resolve() {
    case "$prev" in
        -A*)
            __p4_compflags "a b c d m t Q"
            ;;
        -a*)
            __p4_compflags "s m f t y"
            ;;
        -d*)
            __p4_compflags "b w l n c s u"
            ;;
        -c)
            __p4_complete "$(__p4_changes pending)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-A -a -d -f -n -N -o -t -v -c"
            ;;
        *)
            __p4_filenames
            ;;
    esac
}

# resolved -- Show files that have been resolved but not submitted
#
# p4 resolved [-o] [file ...]
_p4_resolved() {
    case "$cur" in
        -*)
            __p4_complete "-o"
            ;;
        *)
            __p4_filenames
            ;;
    esac
}

# revert -- Discard changes from an opened file
#
# p4 revert [-a -n -k -w -c changelist# -C client] file ...
_p4_revert() {
    p4client=$(__p4_find_val "-C")
    case "$prev" in
        -c)
            __p4_complete "$(__p4_mychanges pending)"
            return ;;
        -C)
            __p4_complete "$(__p4_clients)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-a -n -k -w -c -C"
            ;;
        *)
            __p4_filenames
            ;;
    esac
}

# review -- List and track changelists (for the review daemon)
#
# p4 review [-c changelist#] [-t counter]
_p4_review() {
    case "$prev" in
        -c)
            __p4_complete "$(__p4_changes)"
            return ;;
    esac

    __p4_complete "-c -t"
}

# reviews -- List the users who are subscribed to review files
#
# p4 reviews [-C client] [-c changelist#] [file ...]
_p4_reviews() {
    p4client=$(__p4_find_val "-C")
    case "$prev" in
        -C)
            __p4_complete "$(__p4_clients)"
            return ;;
        -c)
            __p4_complete "$(__p4_changes submitted)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-C -c"
            ;;
        *)
            __p4_filenames
            ;;
    esac
}

# set -- Set or display Perforce variables
#
# p4 set [-q] [-s -S service] [var=[value]]
_p4_set() {
    case "$cur" in
        -*)
            __p4_complete "-q -s -S"
            ;;
        *)
            __p4_complete "$(__p4_vars)"
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
_p4_shelve() {
    case "$prev" in
        -a)
            __p4_complete "$__p4_submitopts"
            return ;;
        -c)
            __p4_complete "$(__p4_mychanges pending)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-Af -p -a -i -f -r -c -As -d -c"
            ;;
        *)
            __p4_filenames
            ;;
    esac
}

# status    -- 'reconcile -n + opened' (output uses local paths)
# status -A -- synonym for 'reconcile -ead' (output uses local paths)
#
# p4 status [-c change#] [-A | [-e -a -d] | [-s]] [-f -I -m] [file ...]
_p4_status() {
    case "$prev" in
        -c)
            __p4_complete "$(__p4_mychanges pending)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-c -A -e -a -d -s -f -I -m"
            ;;
        *)
            __p4_filenames
            ;;
    esac
}

# sizes -- Display information about the size of the files in the depot
#
# p4 sizes [-a -S] [-s | -z] [-b size] [-h|-H] [-m max] file[revRange] ...
# p4 sizes -A [-a] [-s] [-b size] [-h|-H] [-m max] archivefile...
# p4 sizes -U unloadfile ...
_p4_sizes() {
    case "$cur" in
        -*)
            __p4_complete "-a -S -s -z -b -h -H -m -A -U"
            ;;
        *)
            __p4_compfilerev
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
_p4_stream() {
    case "$prev" in
        -t)
            __p4_complete "$(__p4_streamtypes)"
            return ;;
        resolve)
            __p4_complete "-a -n -o"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-f -d -P -t -o -v -i edit resolve revert"
            ;;
        *)
            __p4_complete "$(__p4_streams)"
            ;;
    esac
}

# streams -- Display list of streams
#
# p4 streams [-U -F filter -T fields -m max] [streamPath ...]
_p4_streams() {
    __p4_complete "-U -F -T -m"
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
_p4_submit() {
    case "$prev" in
        -f)
            __p4_complete "$__p4_submitopts"
            return ;;
        --noretransfer)
            __p4_complete "0 1"
            return ;;
        -c)
            __p4_complete "$(__p4_mychanges pending)"
            return ;;
        -e)
            __p4_complete "$(__p4_mychanges shelved)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-Af -r -s -f --noretransfer -d -c -e -i"
            ;;
        --*)
            __p4_complete "--noretransfer"
            ;;
        *)
            __p4_filenames
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
_p4_sync() {
    case "$cur" in
        -*)
            __p4_complete "-f -L -n -N -k -q -r -m -s -p"
            ;;
        *)
            __p4_compfilerev
            ;;
    esac
}

# tag -- Tag files with a label
#
# p4 tag [-d -g -n -U] -l label file[revRange] ...
_p4_tag() {
    case "$prev" in
        -l)
            __p4_complete "$(__p4_labels)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-d -g -n -U -l"
            ;;
        *)
            __p4_compfilerev
            ;;
    esac
}

# unlock -- Release a locked file, leaving it open
#
# p4 unlock [-c | -s changelist# | -x] [-f] [file ...]
# p4 -c client unlock [-f] -r
_p4_unlock() {
    case "$prev" in
        -c)
            __p4_complete "$(__p4_mychanges pending)"
            return ;;
        -s)
            __p4_complete "$(__p4_mychanges shelved)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-c -s -x -f -r"
            ;;
        *)
            __p4_filenames
            ;;
    esac
}

# unshelve -- Restore shelved files from a pending change into a workspace
#
# p4 unshelve -s changelist# [options] [file ...]
# Options: [-A<f|s> -f -n] [-c changelist#]
#          [-b branch|-S stream [-P parent]]
_p4_unshelve() {
    case "$prev" in
        -s)
            __p4_complete "$(__p4_mychanges shelved)"
            return ;;
        -c)
            __p4_complete "$(__p4_mychanges pending)"
            return ;;
        -b)
            __p4_complete "$(__p4_branches)"
            return ;;
        -S)
            __p4_complete "$(__p4_streams)"
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "-s -Af -As -f -n -c -b -S -P"
            ;;
        *)
            __p4_filenames
            ;;
    esac
}

# update -- synonym for 'sync -s'
_p4_update() {
    case "$cur" in
        -*)
            __p4_complete "-L -n -N -q -m"
            ;;
        *)
            __p4_filenames
            ;;
    esac
}

# user -- Create or edit a user specification
#
# p4 user [-f] [name]
# p4 user -d [-f] name
# p4 user -o [name]
# p4 user -i [-f]
_p4_user() {
    case "$cur" in
        -*)
            __p4_complete "-f -d -o -i"
            ;;
        *)
            __p4_complete "$(__p4_users)"
            ;;
    esac
}

# users -- List Perforce users
#
# p4 users [-l -a -r -c] [-m max] [user ...]
_p4_users() {
    case "$cur" in
        -*)
            __p4_complete "-l -a -r -c -m"
            ;;
        *)
            __p4_complete "$(__p4_users)"
            ;;
    esac
}

# where -- Show how file names are mapped by the client view
#
# p4 where [file ...]
_p4_where() {
    __p4_filenames
}

__p4_global_opts() {
    case "$prev" in
        -c)
            __p4_complete "$(__p4_clients)"
            return ;;
        -C)
            __p4_complete "$__p4_charsets"
            return ;;
        -d)
            __p4_directories
            return ;;
        -u)
            __p4_complete "$(__p4_users)"
            return ;;
        -x)
            __p4_filenames
            return ;;
    esac

    case "$cur" in
        -*)
            __p4_complete "$__p4_g_opts"
            ;;
        *)
            __p4_complete "$__p4_cmds"
            ;;
    esac
}

_p4() {
    local cur prev words cword
    _init_completion -n : cur prev words cword || return

    local p4client p4user p4stream p4chstat
    local cmd=$(__p4_find_cmd)
    if [ -z "$cmd" ]; then
        __p4_global_opts
    elif [ "$cur" == "$cmd" ]; then
        __p4_complete "$__p4_cmds"
    else
        local compfunc="_p4_${cmd}"
        declare -f $compfunc >/dev/null && $compfunc
    fi
}

complete -o bashdefault -o default -F _p4 p4
