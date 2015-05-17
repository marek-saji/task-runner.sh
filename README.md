Simple bash task runner
=======================

## Usage

1. Create a tasks runner file:

        #!/bin/bash

        function nonStaticAccess ()
        {
            tail -f /var/log/httpd/access.log |
                grep -Pv '/(image|css|js)/'
        }

        . PATH_TO/task-runner.sh

        register_task 'task name' 'command'
        register_task 'dev-server' 'python -m SimpleHTTPServer'
        register_task 'error' 'tail -f /var/log/httpd/error.log'
        register_task 'access' 'nonStaticAccess'

        run_tasks

2. Run it.

3. Enjoy coloured and timestamped output.
