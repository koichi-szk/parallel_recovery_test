#!/bin/bash
. conf.sh

# To switch among multiple versions of postgres (and EPAS),
# I have "pgmode" shell script.   You may need your owwn ones
# to add postgres/EPAS path to $PATH and $LD_LIBRARY_PATH.
pgmode pg14_pr

pg_ctl -c start -D $TESTDB
