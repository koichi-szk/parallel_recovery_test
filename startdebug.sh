#!/bin/bash
. conf.sh
cd $TESTDB/pr_debug
tail -f pr_debug.log
