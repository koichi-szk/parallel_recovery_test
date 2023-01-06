#!/bin/bash
. conf.sh
pgmode pg14_pr
pg_ctl stop -D $TESTDB
rm -f $TESTDB/postmaster.pid
