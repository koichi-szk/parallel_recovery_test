#!/bin/bash
#
# This script terminates all the postgrs process and cleans up
# postmaster pid file.
#
# This is needed in parallel recovery test run to kill running
# processes quickly for further actions.
#
cd $HOME/parallel_recovery_test
source conf.sh

# To switch among multiple versions of postgres (and EPAS),
# I have "pgmode" shell script.   You may need your owwn ones
# to add postgres/EPAS path to $PATH and $LD_LIBRARY_PATH.
pgmode pg14_pr

killall -9 postgres

rm -f $TESTDB/postmaster.pid
