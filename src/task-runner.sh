#!/bin/bash

if ! [ "$( dirname "${SHELL}" )" ]
then
    echo "Task runner requires to be run as a bash script."
    echo "Sorry about that."
fi

set -e

DATE_FORMAT="%FT%T"

# ( "NAME1" "CMD1" "NAME2" "CMD2" ... )
TASKS=()
MAX_TASK_NAME_LEN=0

USE_COLOUR=0
if [ -t 1 ]
then
    NCOLOURS="$( tput colors )"
    if [ -n "${NCOLOURS}" ] && [ "${NCOLOURS}" -ge 8 ]
    then
        USE_COLOUR=1
    fi
fi

####
# Register a task to be run with run_tasks
#
# $1 - name
# $2 - command
register_task ()
{
    TASKS=( "${TASKS[@]}" "$1" "$2" )
    TASK_NAME_LEN="$( echo -n "$1" | wc -c )"
    if [ ${TASK_NAME_LEN} -gt ${MAX_TASK_NAME_LEN} ]
    then
        MAX_TASK_NAME_LEN=${TASK_NAME_LEN}
    fi
}

####
# Run tasks registered with register_task
run_tasks ()
{
    local TASK_PIDS=()

    local NAME=
    local CMD=
    local DATA_IS_NAME=0
    local DATA=
    local IDX=-1

    for DATA in "${TASKS[@]}"
    do
        DATA_IS_NAME=$(( ( DATA_IS_NAME + 1 ) % 2 ))
        IDX=$(( IDX + 1 ))

        if (( DATA_IS_NAME ))
        then
            NAME="${DATA}"
        else
            CMD="${DATA}"

            __run_task "${NAME}" "${CMD}" "$(( IDX / 2 ))" &
            TASK_PIDS=( "${TASK_PIDS[@]}" $! )
        fi
    done

    wait "${TASK_PIDS[@]}"
}


####
# Run a task
#
# $1 - name
# $2 - command
# $3 - index
__run_task ()
{
    local NAME="$1"
    local CMD="$2"
    local IDX="$3"
    local PID=

    ((
        sleep 1
        eval "$CMD"
    ) 1> >( __read_lines "${NAME}" 1 "${IDX}")
    ) 2> >( __read_lines "${NAME}" 2 "${IDX}") \
    & PID=$!

    __print_message "${NAME}" "HI!" "Job started. PID=${PID}" "${IDX}"
    wait ${PID}
    __print_message "${NAME}" "END" "Job ended. PID=${PID}" "${IDX}"
}


####
# Read lines from standard input and print using __print_message
#
# $1 - name
# $2 - number of file description output comes from
# $3 - index
__read_lines ()
{
    local NAME="$1"
    local FN="$2"
    local IDX="$3"
    local LINE_TYPE="???"
    local LINE=

    if [ "$FN" = 1 ]
    then
        LINE_TYPE=OUT
    elif [ "$FN" = 2 ]
    then
        LINE_TYPE=ERR
    fi

    while read -r LINE
    do
        __print_message "${NAME}" "${LINE_TYPE}" "${LINE}" "${IDX}"
    done
}

####
# Print task's message
#
# $1 - name
# $2 - type (should have three letters)
# $3 - message
# $4 - index
__print_message ()
{
    local NAME="$1"
    local TYPE="$2"
    local MESSAGE="$3"
    local IDX="$4"

    local DATE="$( date +"${DATE_FORMAT}" )"

    local COLOUR_RESET=""
    local COLOUR_META=""
    local COLOUR_MESSAGE=""
    local COLOUR_TASK=

    if (( ${USE_COLOUR} ))
    then
        COLOUR_RESET="\e[0;0m"
        COLOUR_META="\e[1;30m"
        case "${TYPE}" in
            "OUT" ) COLOUR_MESSAGE="" ;;
            "ERR" ) COLOUR_MESSAGE="\e[31m" ;;
            "END" ) COLOUR_MESSAGE="\e[1;31m" ;;
            * )     COLOUR_MESSAGE="\e[34m" ;;
        esac
        COLOUR_MESSAGE="${COLOUR_RESET}${COLOUR_MESSAGE}"
        # Bash/ASCII colours from 32 (green) to 36 (cyan),
        COLOUR_TASK="\e[0;$(( 32 + ( ( IDX + 1 ) % 5 ) ))m"
    fi

    printf "${COLOUR_META}%s %s ${COLOUR_TASK}%- ${MAX_TASK_NAME_LEN}s ${COLOUR_META}| ${COLOUR_MESSAGE}%s${COLOUR_RESET}\n" \
        "${DATE}" "${TYPE}" "${NAME}" \
        "${MESSAGE}"
}
