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

This script is used to create test database.   The script runs initdb, start it and run pgbench to create several WAL segments for the test and then stop immediately to leave as many outstanding WALs as possible.   The material will be archived with tar for later reuse.

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

## Run the test

### `rstore.sh`

You need to run this script to prepare the test database.  This restore archived test database and replace `postgresql.conf` which contains several additioanl GUC parameters to enable parallel replay.

### Prepare your terminal:

You need terminals for the following purpose:

* Main control of the test: runs `pg_ctl start` and do following tasks.
* Terminal to show debug information: This is needed to display test information, including scripts to start gdb for each workers.
* Terminal for gdb for startup proces (READER WORKER)
* Terminal for gdb for dispatcher worker,
* Terminal for gdb for transaction worker,
* Terminal for gdb for invalid block worker,
* Terminal for gdb for block worker: You may need more than one depending upon `num_preplay_workers` GUC parameter value.

### `start.sh` script

You should run this script in main control terminal.   This will show output from `pg_ctl start` and then wait.   It's fine.   Please leave as is.

```
[koichi@ksubuntu:pr_test]$ start.sh
waiting for server to start....2023-01-05 17:51:58.295 JST [1090620] LOG:  ?????????????????????????
2023-01-05 17:51:58.295 JST [1090620] ???:  ????????????????"log"??????
```

### `startdebug.sh` script and run gdb against reader worker (startup process)

After you run `start.sh`, PostgreSQL server start to run and fork start startup process (READER worker).  Startup process will then write some messages to `$PGDATA/pr_debug` file and waits for your intervention.

Please run `startdebug.sh` script at the second terminal as shown above.  You will see the output like:

```
[koichi@ksubuntu:pr_test]$ startdebug.sh
My worker idx is 0.
Please touch /home/koichi/pg14_pr_database/pr_debug/0.signal to begin.  I'm waiting for it.

Do following from another shell:
sudo gdb \
-ex 'attach 1090918' \
-ex 'tb PRDebug_sync' \
-ex 'source reader_break.gdb' \
-ex 'shell touch  /home/koichi/pg14_pr_database/pr_debug/0.signal' \
-ex 'continue'
```

Please copy and past the obove shell script from `sudo` to the end of the line to run gdb, attach reader worker process to it, attach signal file reader worker is waiting and then continue its run.

The file `reader_break.gdb` file contains initial gdb commands to run.   Typically, it defines shortcut macro and breakpoints.   You can change this file as you like.

Typical contents of this file is as follows:

```
# command definition, shortcut for "finish"
define f
finish
end
define c
continue
end
b PR_enqueue
b PR_fetchQueue
b PR_breakpoint_func
b ReadRecord
```

`ReadRecord` is a function in `xlog.c` which reads one `XLogRecord`.   If this is in your breakpoint list, then the reader worker will read one or two XLogRecord before it starts redo.   In this case, please type c until you have additional lines in `startdebug.sh` shell script terminal.


### Run gdb against dispatcher worker

Then, you will see additional lines of output similar to the above to attach gdb to dispatcher worker.

In another termianl window for dispatcher worker, please copy and paste the output to the shell to run gdb, attach it to the dispatcher worker and keep run.  In the shell script shown at the terminal window, you will see the file `dispatcher_worker_break.gdb` instead to use initial gdb commands to run.  The typical contents is as follows:

```
define f
finish
end
define c
continue
end
b PR_enqueue
b PR_fetchQueue
b PR_breakpoint_func
b dispatcherWorkerLoop
b DecodeXLogRecord
b DecodeXLogRecordBlockInfo
```

### Run gdb against transaction worker
