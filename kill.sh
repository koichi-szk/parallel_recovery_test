#!/bin/bash
. conf.sh
pgmode pg14_pr
killall -9 postgres
rm -f $TESTDB/postmaster.pid
