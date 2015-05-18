#!/bin/sh

set -e

cd "$( dirname "$0" )"

script -c "export DATE_FORMAT='(DATE)' ; ./test-tasks.sh" | grep -Pv '^Script' | sed -r -e 's/PID=[0-9]+/PID=$!/' | sort | tee test-typescript
diff test-typescript expected-typescript
