#!/bin/bash
cd $HOME/parallel_recovery_test
. conf.sh

# To switch among multiple versions of postgres (and EPAS),
# I have "pgmode" shell script.   You may need your owwn ones
# to add postgres/EPAS path to $PATH and $LD_LIBRARY_PATH.
#
# pg14_pr is pgmode argument to setup environment to run
# PostgreSQL14 with parallel replay patch.
pgmode pg14_pr

pg_ctl -c start -D $TESTDB
