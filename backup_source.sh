#!/bin/bash
cd $HOME/parallel_recovery_test
. ./conf.sh
function do_backup
{
	cp $SRCDIR/$1 $SRCBACKUPDIR/`basename $1`_`date +%Y%m%d_%H%M`
}
do_backup src/backend/access/transam/xlog.c
do_backup src/backend/access/transam/parallel_replay.c
do_backup src/include/access/parallel_replay.h
