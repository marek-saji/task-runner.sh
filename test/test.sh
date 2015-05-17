#!/bin/sh

set -e

cd "$( dirname "$0" )"

script -c "./test-tasks.sh" | grep -Pv '^Script' | sed -r -e 's/PID=[0-9]+/PID=$!/' -e 's/[0-9]{4}(-[0-9]{2}){2}T[0-9]{2}(:[0-9]{2}){2}/YYYY-MM-DDTHH:MM:SS/' | sort > test-typescript
diff test-typescript expected-typescript
