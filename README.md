# Testing Parallel Recovery

Koichi Suzuki

## Overview

It is not simple to test parallel recovery at debugger level.   In normal PG code running as a part of transaction runs in single backend process.   PID is exposed and we can attach such backend process before we test any code running there.   Because parallel recovery workers run as startup process or its child processes, recovery code runs just after Postmaster starts and before it begins to accept connections, we need separate measn to connect gdb to such workers without pain.   This material provides several means to do so.

It is know that with current parallel recovery code, actual data pages conflict with some of corresponding WAL records, especially in multi-insert operation done as a part of HEAP2 resource manager code.

We may need good amount of work to fix them and before this, we'd like to show that parallel recovery is scalable and is worth moving forward.

This material describes how such test code is written and how you can use this to test the code under your environment.

For more about parallel recovery architecture, please visit Koichi Suzuki's [PostgreSQL Wiki page](https://wiki.postgresql.org/wiki/Parallel_Recovery).

## Build and test environment

Bash script `conf.sh` specifies several environment variable for the configuration of the place of the source code directory (very likely your local git repository), directory of this material, target of the binary and test database.

You will find `pgmode` command.   This defines installation target of PG binaries and libraries.   This function is outside of the material and you can specify installation target and include them to `PATH` and `LD_LIBRARY_PATH`.

Please contact me if you need details about `pgmode` command.  I wrote this script to test many different versions/variants of PostgreSQL/EPAS databases without pain.

## Compile options for the test

Here's two compile flags for the test.

### `WAL_DEBUG`

This flag is existing one and we use this flag to place all the debug code to connect to gdb and trace each worker's execution.

### `PR_IGNORE_REPLAY_ERROR`

This flag is used to ignore any conflict/error in existing replay functions. If you build PG with this option (with `-DPR_IGNORE_REPLAY_ERROR`), when any error occurs within reply codes and it leads to process exit (`ERROR` or higher elevel), it will jump back to the point to invoke redod code for the check that there are errors in replay.  If we repeat to ignore such errors, where can be good chance that replay functions may result in SIGSEGV.   This option also handles SIGSEGV signal and to jump back to the same point.

## Scripts to build binaries

The following scripts assume that the source materials are placed under `$SRCDIR`.

Make and install logs are stored in `log` directory in this material.

### `configure.sh` 

This script runs `configure` script to configure build environment and its target.   As default, it includes the following:

* `O0` flags to make optimization minimum so that all the steps and variables are visible to gdb.
* `-DWALDEBUG` flag to enable painless connection of replay workers to gdb.
* `-DPR_IGNORE_REPLAY_ERROR` flag to ignore any internal conflict in existing WAL replay functions.
* `-DPR_SKIP_REPLAY` flag.  This flag replaces actual replay function call with dummy wait.  This flag is useful to test surrounding infrastructures of WAL record reading, dispatch and synchronization among workers.

### `build.sh`

Runs `make` and `make check` automatically.   `Make` will run with multi-process.  Please tweak the number of processes to meet your environment.

### `cleanbuild.sh`

Runs `make clean`, `make` and `make check`.   If you modify any header files `*.h`, these changes are not detected by Makefile.  You need to run this script to have all the header file changes to the build.   `Make` will run with multi-process.  Please tweak the number of processes to meet your environment.

### `install.sh`

Runs `make install`.   This does not run as superuser.   It is assumed that installation target is not owned by the superuser.

### `htag.sh`

Runs `gtags` and `htags` to create source code reference and links.   You need to install gtags and htags for this script.

## Create the test database

You need separate binary of PostgreSQL 14 without parallel recovery capability, as specified by `pg14` value by `pg_mode`.  You can use binaries build by scripts here and run it disabling parallel recovery.   This material is using separate one just in case.   Please note that the binary build here passes all the `make check`, which runs disabling parallel recovery.

### Additional GUC parameters to control the parallel recovery

We have several additional GUC parameters to enable and control the parallel recovery:

* `parallel_replay` (boolean): default is `off`.  If you set this to `on`, parallel recovery is enabled and will run with more than one replay worker.
* `parallel_replay_test` (boolean): default is `off`.  If set to `on`, it will enable additional feature to test parallel replay with gdb.
* `num_preplay_workers` (integer); default is 7.   Specifies number of parallel replay workers including startup process.  Numinum is 5.
* `num_preplay_queues` (integer): default is 128.   Specifies number of queues used to assign replay data (mainly WAL records) from worker to worker.  If it is too small, then queue will run out and workers have to wait until existing queues are consumed and released.
* `num_preplay_max_txn` (integer): default is `max_connection` value.  Specifis number of entries for active transaction.  If you run prallel replay at log-shipping replication standbys, you should specify this value for the value of its primary's `max_connection` at least. If there's more active transactions than this configuration, recovery will exit and the database stays in inconsistency state (you need to increase this number and start the database again to rerun the recovery).
* `preplay_buffers` (size): default is 4MB.   Specifies the amount of the shared memory allocated for the parallel replay.   The memory will be allocated using dynamic shared memory and will be released when the recovery finishes.

### `create.sh`

This script is used to create test database.   The script runs initdb, start it and run pgbench to create several WAL segments for the test and then stop immediately to leave as many outstanding WALs as possible.   The material will be archived with tar for later reuse.  No parameters.

This creates default database for my login name (`koichi`).  Please change this to your favorite value.

## Breakpionts for each worker

You can define gdb brakpoints for each worker process in the following files.   You can write any gdb commands in these files.  They wll run just after each worker process is attached to gdb.

### `reader_break.gdb`

Initial gdb command runs just after the reader worker (in fact startup process) is attached to gdb.  As a default, we define `ReadRecord` and `DecodeXLogRecord` as breakpoints.  In this case, these function will be called before other workers start.   You may type `c` command until the reader worker begins to start other workers (some more description will be given later).   invokes `PR_enqueue` to pass actual XLog record to the dispatcher.  

### `dispatcher_worker_break.gdb`

Initial gdb commands which run after dispatcher worker is attached to gdb.

### `txn_worker_break.gdb`

Initial gdb commands which run after transaction worker is attached to gdb.

### `invalid_page_worker_break.gdb`

Initial gdb commands which run after invalid page worker is attached to gdb.

### `block_worker_break.gdb`

Initial gdb commands which run after block worker is attached to gdb.

## Other shell scripts

### `rstore.sh`

You need to run this script to prepare the test database.  This restore archived test database and replace `postgresql.conf` which contains several additioanl GUC parameters to enable parallel replay.

### `start.sh`

Run `pg_ctl start`.    For details, please take a look at `RunningTest.md`.  No parameeters.

### `startdebug.sh`

Display parallel replay test information.   This will show you how you can attach gdb to each replay worker.    For details, please take a look at `RunningTest.md`.  No parameters.

### `kill.sh`

Kills and terminate all the PostgreSQL processes.   Very typically, you need to terminate the test before postmaster begins to accept connections.   This script is for this purpose.   Don't worry.   The test database is not permanent and you can restore this with `restore.sh` script.   No parameters.

### `backup_log.sh`

Copies latest debug file at `$PGDATA/pr_debug` and `$PGDATA/log` directory to `pr_debuglog` directory and `db_log` directory respectively.
