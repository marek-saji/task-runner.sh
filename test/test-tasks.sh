#!/bin/bash

cd "$( dirname "$0" )"

. ../src/task-runner.sh

bash_function ()
{
    bash dummy.sh three
}

register_task one "bash dummy.sh 'command'"
register_task two "bash dummy.sh 'command'"
# bash functions
register_task three "bash_function"
# colours
register_task four "printf \"\\e[35mflying colours!\n\""
# piping
register_task five "bash dummy.sh five | grep 'i am'"

run_tasks
