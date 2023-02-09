#!/bin/bash
cd $HOME/parallel_recovery_test
source ./conf.sh
cp $(ls -l $TESTDB/pr_debug//pr_debug.log | cut -d " " -f 13) pr_debuglog
cp $TESTDB/log/$(ls -lt $TESTDB/log | head -n 2 | tail -n 1 | cut -d " " -f 11) db_log
