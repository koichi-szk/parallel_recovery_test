#!/bin/bash
. ./conf.sh
logf=$LOGDIR/make_`shortdate`.log
cd $SRCDIR
(make clean; make -j 8; make check) |& tee $logf
