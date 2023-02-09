#!/bin/bash
#
# Run htag to create HTML docs for the source.
#
cd $HOME/parallel_recovery_test
. conf.sh
cd $SRCDIR/src
htags -g -n -h --tabs 4
rm -rf $HTAGDIR
mkdir -p $HTAGDIR
mv HTML $HTAGDIR
