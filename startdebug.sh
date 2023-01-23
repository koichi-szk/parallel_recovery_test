#!/bin/bash
#
# After running "start.sh" script, run this script at different teminal window.
# This will display additional debug information, including instructions
# to connect gdb to various parallel replay worker processes, including
# READER (in fact, Startup), DISPATCHER, TXN, INVALID BLOCK and BLOCK workers.
#
# When built with -DWAL_DEBUG option, the database will display instructions
# to run gdb, attach the worker to it and run initial gdb scripts including
# defining initial commands and break point definitions.
#
# For break point definitions of each replay worker, please take a look at
# the file *.gdb.
#
. conf.sh
cd $TESTDB/pr_debug
tail -f pr_debug.log
