#!/bin/bash
cd $HOME/parallel_recovery_test
source conf.sh
pgmode pg14_pr
pg_ctl stop -m immediate -D $TESTDB
rm -f $TESTDB/postmaster.pid
backup_log.sh
