#!/bin/bash
cd $HOME/parallel_recovery_test
source ./conf.sh
logf=$LOGDIR/make_`shortdate`.log
cd $SRCDIR
(make -j 8; make check) |& tee $logf
