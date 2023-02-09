#!/bin/bash
#
# Install test binaries
cd $HOME/parallel_recovery_test
source ./conf.sh
logf=$LOGDIR/install_`shortdate`.log
cd $SRCDIR
make install |& tee $logf
