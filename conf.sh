#!/bin/bash
export DBDIR=$HOME
export DBHOME=pg14_pr_database
export TESTDIR=$HOME/parallel_recovery_test
export SRCDIR=/hdd2/koichi/postgres-parallel_recovery_14_6/postgres
export TESTDB=$DBDIR/$DBHOME
export LOGDIR=$TESTDIR/log
export HTAGDIR=/hdd2/koichi/postgres_htag/REL_14_6_PR
pgmode pg14_pr
