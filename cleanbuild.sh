#!/bin/bash
cd $HOME/parallel_recovery_test
source ./conf.sh
./backup_source.sh
logf=$LOGDIR/make_`shortdate`.log
cd $SRCDIR
(make clean; make -j 8; make check) |& tee $logf
