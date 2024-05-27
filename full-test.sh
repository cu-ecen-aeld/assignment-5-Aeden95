#!/bin/bash
# This script can be copied into your base directory for use with
# automated testing using assignment-autotest.  It automates the
# steps described in https://github.com/cu-ecen-5013/assignment-autotest/blob/master/README.md#running-tests
set -e

cd `dirname $0`
test_dir=`pwd`
echo "starting test with SKIP_BUILD=\"${SKIP_BUILD}\" and DO_VALIDATE=\"${DO_VALIDATE}\""

# This part of the script always runs as the current user, even when
# executed inside a docker container.
# See the logic in parse_docker_options for implementation
logfile=test.sh.log
# See https://stackoverflow.com/a/3403786
# Place stdout and stderr in a log file
exec > >(tee -i -a "$logfile") 2> >(tee -i -a "$logfile" >&2)

echo "Running test with user $(whoami)"

set +e

# If there's a configuration for the assignment number, use this to look for
# additional tests
if [ -f conf/assignment.txt ]; then
    # This is just one example of how you could find an associated assignment
    assignment=`cat conf/assignment.txt`
    if [ -f ./assignment-autotest/test/${assignment}/assignment-test.sh ]; then
        echo "Executing assignment test script"
        timeout 2113s bash -c './assignment-autotest/test/${assignment}/assignment-test.sh $test_dir'
        rc=$?
        echo "Test of assignment ${assignment} complete with success"
        exit 0
    else
        echo "No assignment-test script found for ${assignment}"
        exit 0
    fi
else
    echo "Missing conf/assignment.txt, no assignment to run"
    exit 0
fi
exit 0
