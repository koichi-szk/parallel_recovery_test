#!/bin/bash
cd $HOME/parallel_recovery_test
source ./conf.sh
cp $TESTDB/pr_debug/[0-9]*_pr_debug.log pr_debuglog
cp $TESTDB/log/*.log db_log
