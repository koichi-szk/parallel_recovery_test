#!/bin/bash
. ./conf.sh
logf=$LOGDIR/configure_`shortdate`.log
cd $SRCDIR
./configure --prefix=/home/koichi/pg14_pr --enable-debug --with-perl --with-python --with-openssl --enable-nls --with-libxml --with-libxslt --with-systemd --with-lz4 --with-tcl CFLAGS="-O0 -DWAL_DEBUG -DPR_IGNORE_REPLAY_ERROR" CC=/usr/bin/gcc |& tee $logf
