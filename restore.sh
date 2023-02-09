#!/bin/bash
#
# Restore test databaes
cd $HOME/parallel_recovery_test
source conf.sh
rm -rf $TESTDB
pwd=`pwd`
cd $DBDIR
tar xf $TESTDIR/$DBHOME.tgz
cp $TESTDIR/postgresql.conf $DBDIR/$DBHOME
cp $TESTDIR/pg_hba.conf $DBDIR/$DBHOME
