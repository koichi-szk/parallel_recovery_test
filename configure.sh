#!/bin/bash
cd $HOME/parallel_recovery_test
source ./conf.sh
logf=$LOGDIR/configure_`shortdate`.log

# Please specify O0 as OPTIMIZE_LEVEL to avoid "optimized out"
# statements or variables to run with gdb.
OPTIMIZE_LEVEL=O0

# -DWAL_DEBUG enables additional log about WAL replay and enables
#			  to run startup process and parallel replay workers
#			  from gdb.
#
# -DPR_IGNORE_REPLAY_ERROR ignores any replay error during the
#			recovery.   This is essential to test the whole
#			parallel recovery framework and measure potential
#			performance gain.
#
DEBUGFLAGS="-DWAL_DEBUG -DPR_IGNORE_REPLAY_ERROR -DPR_SKIP_REPLAY"
CFLAGS="CFLAGS=\"-$OPTIMIZE_LEVEL $DEBUGFLAGS\""

# On some operating system like Ubuntu22.04, you may specify the path
# to C compiler.
CC="CC=/usr/bin/gcc"

# Target directory for the installation.   Here, we don't care about
# separate target directory for libraries, header files and documents.
# Everything is installed under this directory.
TARGET_DIR="/home/koichi/pg14_pr"

cd $SRCDIR
./configure --prefix=$TARGET_DIR --enable-debug --with-perl --with-python --with-openssl --enable-nls --with-libxml --with-libxslt --with-systemd --with-lz4 --with-tcl CFLAGS="-O0 $DEBUGFLAGS" $CC |& tee $logf
