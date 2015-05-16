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
    TASK_PIDS=()

    NAME=
    CMD=
    DATA_IS_NAME=0
    for DATA in "${TASKS[@]}"
    do
        DATA_IS_NAME=$(( ( DATA_IS_NAME + 1 ) % 2 ))

        if (( DATA_IS_NAME ))
        then
            NAME="${DATA}"
        else
            CMD="${DATA}"

            __run_task "${NAME}" "${CMD}" &
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
__run_task ()
{
    NAME="$1"
    CMD="$2"

    ((
        sleep 1
        eval "$CMD"
    ) 1> >( __read_lines "${NAME}" 1 )
    ) 2> >( __read_lines "${NAME}" 2 ) \
    & PID=$!

    __print_message "${NAME}" "HI!" "Job started. PID=${PID}"
    wait ${PID}
    __print_message "${NAME}" "END" "Job ended. PID=${PID}"
}


####
# Read lines from standard input and print using __print_message
#
# $1 - name
# $2 - number of file description output comes from
__read_lines ()
{
    NAME="$1"
    FN="$2"

    if [ "$FN" = 1 ]
    then
        LINE_TYPE=OUT
    elif [ "$FN" = 2 ]
    then
        LINE_TYPE=ERR
    fi

    while read -r LINE
    do
        __print_message "${NAME}" "${LINE_TYPE}" "${LINE}"
    done
}

####
# Print task's message
#
# $1 - name
# $2 - type (should have three letters)
# $3 - message
__print_message ()
{
    NAME="$1"
    TYPE="$2"
    MESSAGE="$3"

    DATE="$( date +"${DATE_FORMAT}" )"

    if (( ${USE_COLOUR} ))
    then
        COLOUR_RESET="\e[;0m"
        COLOUR_META="\e[1;30m"
        case "${TYPE}" in
            "OUT" ) COLOUR_MESSAGE="" ;;
            "ERR" ) COLOUR_MESSAGE="\e[31m" ;;
            "END" ) COLOUR_MESSAGE="\e[1;31m" ;;
            * )     COLOUR_MESSAGE="\e[34m" ;;
        esac
        COLOUR_MESSAGE="${COLOUR_RESET}${COLOUR_MESSAGE}"
    else
        COLOUR_RESET=""
        COLOUR_META=""
        COLOUR_MESSAGE=""
    fi

    printf "${COLOUR_META}%s %s %- ${MAX_TASK_NAME_LEN}s ${COLOUR_MESSAGE}%s${COLOUR_RESET}\n" \
        "${DATE}" "${TYPE}" "${NAME}" \
        "${MESSAGE}"
}
