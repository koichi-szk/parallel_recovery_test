#!/bin/bash
cd $HOME/pr_test
. conf.sh
rm -rf $TESTDB
pwd=`pwd`
cd $DBDIR
tar xf $TESTDIR/$DBHOME.tgz
cp $TESTDIR/postgresql.conf $DBDIR/$DBHOME
