#!/bin/bash
. ./conf.sh
logf=$LOGDIR/install_`shortdate`.log
cd $SRCDIR
make install |& tee $logf
