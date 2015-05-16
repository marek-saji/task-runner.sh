Simple bash task runner
=======================

USAGE:

Create a runner file

    #!/bin/bash

    . PATH_TO/task-runner.sh

    register_task 'task name' 'command'
    register_task 'access' 'tail -f /var/log/httpd/access.log'
    register_task 'error' 'tail -f /var/log/httpd/error.log'
    register_task 'dev-server' 'python -m SimpleHTTPServer'

    run_tasks
