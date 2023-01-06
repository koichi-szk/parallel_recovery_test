# command definition, shortcut for "finish"
define f
finish
end
define c
continue
end
# b PR_debug_buffer
# b PR_debug_buffer2
# b PR_WorkerStartup
# b ParallelRedoProcessMain
# b PR_atStartWorker
# b dispatcherWorkerLoop
# b txnWorkerLoop
# b invalidPageWorkerLoop
# b blockWorkerLoop
# b PR_allocBuffer
# b PR_freeBuffer
b PR_enqueue
b PR_fetchQueue
b PR_breakpoint_func
# b PR_recvSync
# b PR_sendSync
# b PRDebug_sync
# b free_chunk
# b PR_allocXLogDispatchData
# b removeTxnCell
# b PR_analyzeXLogReaderState
# b dispatchDataToXLogHistory
# b addDispatchDataToTxn
# b isTxnSyncNeeded
# b XLogReadBufferForRedo
# b XLogReadBufferForRedoExtended
# b XLogInitBufferForRedo
# b PathNameOpenFile
b DecodeXLogRecord
# `b DecodeXLogRecordBlockInfo
b heap_xlog_multi_insert
b PageAddItem
# Breakpoints for redo function entry for each RMID
# b xlog_redo
# b xact_redo
# b smgr_redo
# b clog_redo
# b dbase_redo
# b tblspc_redo
# b multixact_redo
# b relmap_redo
# b standby_redo
# b heap2_redo
# b heap_redo
# b btree_redo
# b hash_redo
# b gin_redo
# b gist_redo
# b seq_redo
# b spg_redo
# b brin_redo
# b commit_ts_redo
# b replorigin_redo
# b generic_redo
# b logicalmsg_redo
