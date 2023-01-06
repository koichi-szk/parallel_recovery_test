#!/bin/bash
. conf.sh
cd $SRCDIR/src
htags -g -n -h --tabs 4
rm -rf $HTAGDIR
mkdir -p $HTAGDIR
mv HTML $HTAGDIR
