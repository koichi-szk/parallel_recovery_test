#!/bin/bash
cd $HOME/pr_test
. conf.sh
pgmode pg14
rm -rf $TESTDB
initdb $TESTDB
cp postgresql.conf.init $TESTDB/postgresql.conf
cp pg_hba.conf $TESTDB
pg_ctl start -D $TESTDB
psql postgres -c 'create database koichi;'
pgbench -i koichi
pgbench -c 100 -t 50
pg_ctl stop -m immediate -D $TESTDB
cp postgresql.conf $TESTDB
pwd=`pwd`
cd $DBDIR
tar czf $TESTDIR/$DBHOME.tgz $DBHOME
cd $pwd
