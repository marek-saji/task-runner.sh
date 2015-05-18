Simple bash task runner
=======================

[![Build Status](https://travis-ci.org/marek-saji/task-runner.sh.svg?branch=master)](https://travis-ci.org/marek-saji/task-runner.sh)

## Usage

1. Create a tasks runner file:

        #!/bin/bash

        nonStaticAccess ()
        {
            tail -f /var/log/httpd/access.log |
                grep -Pv '/(image|css|js)/'
        }

        . PATH_TO/task-runner.sh

        # You may use commands
        register_task 'task name' 'command'
        register_task 'dev-server' 'python -m SimpleHTTPServer'
        register_task 'error' 'tail -f /var/log/httpd/error.log'
        # or call defined functions
        register_task 'access' 'nonStaticAccess'

        # After registering all tasks, run them,
        # optionally specyfing date format.
        # %T is the default, but you can overwrite it here
        DATE_FORMAT="%FT%T" run_tasks

2. Run it.

3. Enjoy coloured and timestamped output.
