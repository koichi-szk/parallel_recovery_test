#!/bin/bash
. conf.sh
pgmode pg14_pr
pg_ctl -c start -D $TESTDB
