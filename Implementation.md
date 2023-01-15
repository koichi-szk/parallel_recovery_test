# Implementation of PostgreSQL parallel recovery code

## Architecture

* Recovery is done by rplaying WAL record to existing data pages and other database storage resources.
* Idea is to do this in parallel for performance.
* We cannot replay WAL record simply in parallel.  We need to maintain partial graph.

### Fundamental principle to follow even in parallel replay

* For each data page, WAL record must be applied in the order it was written.
* Before replaying WAL terminating a transaction, all the other preceding WAL record for that transaction must have been replayed.
* Because WAL replay order may be partially different from its written order, status of WAL replay can be updated to an LSN when all the preceding WAL have been replayed.
* Order of replaying WAL records where no data blocks are associated, they must be replayed in the written order,
* Storage creation WAL must be replayed before WALS for this storage are replayed,
* Storage deletion WAL must be replayed after all the WAL records for this storage were replayed.
* When timeline changes, all the preceging WAL records have to be replayed.

Handling of multi-block WAL record will be mentioned later.

## Replay workers and their role

For this purpose, we need several different kind of replay worker for different role, as described below.

### Reader worker

Reader worker reads WAL records from various source.   In fact, this is startup process which performs recovery in existing single-thread WAL replay.   We can reuse the following existing functionality:

* Read WAL records from various sources, depending upon recovery state,
* Analysis of the WAL record.   We could do this in other workers such as dispatcher, however, at present, analyzed information is used even in the reader worker including error handling.   We remain this in the role of reader worker so far.
* Determine if the database reaches to a consistent state so that postmaster can accept connection,
* Determine to finish the replay,
* Timeline ID monitoring.

Main part of this reader worker will be found in `xlog.c` source file.

### Dispatcher worker

Dispatcher worker does the following:

* Receives WAL record in the read order by READER worker,
* Determines what worker to handle,
* Maintains informatin of WAL records for each transaction,
* If a WAL record have to be replayed before all the other subceding WAL records, assign this and wait until it has been replayed.
* If timeline changes with a WAL, then waits until all the preceding WALs are replayed, assign this to the transaction worker and waits until it is replayed.

WAL records without associated blocks are assigned to the transaction worker.   WAL records with associated blocks are assigned to one of block workers based on the hash value of relnode id and block number.

If a WAL record is associated with more than one blocks, hash values of these blocks/relnodeid will be calculated and is assigned to block workers for each hash value.   Detailed method will be described in the block worker section.

### Transaction worker

Transaction worker takes care of WAL records without associated block information.   This worker is a separate backgroud process forked from the startup process and do the following:

* Receives WAL records from the dispatcher worker,
* Applies them in the received order,
* If the WAL records requires all the preceding WAL record for the transaction replayed, wait until all the preceding WAL records for this transaction have been replayed,
* If the WAL records requires all the preceding WAL record (not only for specific transaction) replayed, wait until all the preceding WAL records have been replayed.

### Invalid page worker

While replaying WAL records to a specific page, we have a chance to refer to invalid pages.   This happens when data pages are removed at after replaying WALs were written.   This should be corrected when we replay WAL records to remove such invalid pages (and we should have such WAL record).   For this purpose, original PostgreSQL implements general hash based on process-local memory.   Because it is not simple for now, we have this worker dedicated to maintain invalid page information in process local memory, reusing existing code.   We may be able to implement invalid page information based on a shared memory to eliminate the need for this worker.

### Block worker

We can configure more than one block workers for performance.   Dispatcher worker will assign WALs for different page to different configured block worker based on the hash value of relfilenode and block number.   This guarantees that order of WAL records for a give page is assigned in the order of their writes and is replayed in this order for a given page.

This is basic behavior of block worker, very simple.

When a WAL is replayed, the worker removes this WAL from the list of given transaction.   If there's no WAL left in the list and if it is required to report to transaction worker that all the associated WALs are replayed, it sends a sync.   Sync method is described later.

We need to consider one exception.   WAL record can have more than one associated pages, up to 32 (as of version 15).  In this case, it is not appropriate to assign such WAl record to one of the matching worker because order of wal replay may be broken for other pages.

To prevent this, we assign such WAL record to all the matching block workers, together with number of assigned block workers.

For example, if a WAL record has three associated blocks BLK_0, BLK_1, BLK_2 and their hash values are H_0, H_0 and H_1, we assign such WAL record to block worker for H_0 and H_1 (not three, but two, in this case).   If H_0 and H_1 are configured to be handled by the same worker, then this goes to one block worker and there is no difference from single block WAL.  If they are configured to go to different workers, they this WAL has assigned worker number 2 and is assigned to two workers.

When a block worker receives a WAL records associated with more than one block worker, it decrements the remaining worker number.  If it is not zero (still another worker to receive this), this indicates other workers have not received this WAL recorord yet and may have been working to update other blocks in this WAL record.  In this case, the worker cannot simply replay this record yet.  Instead, this worker decrements the remaining number and just wait to receive synchronization from another block worker.

If remaining number of assigned worker becomes zero, it indicates this worker is the last to receive and other workers are wating for this worker to finish to replay this WAL.  Then, this worker can invoke whole replay function and send synchronization to all the other worker wating for this.

## Starting and managing replay worker process

Additional worker process, dispatcher, transaction, invalid pages and block workers are initiated in `StartXlog()` function, before it begins to replay WAL records.

<! Up to here.  Remaining will be added later >

### PRPROC extenxion

## Data sharing among workers

## Assigning WAL records

### including worker termination

## Synchronization mechanism among workers

## Transaction management and synchronization

## WAL replay status management

## Multi-page WAL record handling

## Build flags for debugging and test
