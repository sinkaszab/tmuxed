#!/usr/bin/env bash

DIR="$(dirname "$(readlink "$0")")"

declare -a funcs

subcommand=$1; shift
case "$subcommand" in
    open)
        while getopts 't:f:' opt; do
            case ${opt} in
                t)
                    target=$OPTARG;;
                f)
                    funcs+=( $OPTARG );;
                :)
                    echo "Invalid option -$OPTARG" 1>&2 exit 1;;
                \?)
                    echo "Invalid option -$OPTARG" 1>&2; exit 1;;
            esac
        done
        ;;
    *)
        echo "Invalid subcommand: ${subcommand}." 1>&2
        exit 1
        ;;
esac

. $DIR/tmux_windows.sh

if [ "$subcommand" == 'open' ]
then
    echo "Opening tmux with session name: ${target}."

    tmux has-session -t $target
    if [ $? != 0 ]
    then
        echo 'Creating a new session.'
        tmux new-session -s $target -n scratch -d
    fi

    for func in ${funcs[@]}
    do
        echo "Adding \"$func\" to \"$target\""
        $func $target
    done

    tmux -u attach -t $target
fi
