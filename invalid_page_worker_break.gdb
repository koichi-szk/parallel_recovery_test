# ================================================================================
# Initial command and break point definition for INVALID PAGE worker processes.
#
# You can edit this file to meet your needs.
# Commented-out break points includes major break point candidates.
# ================================================================================
#
# command definition, shortcut for "finish" and "continue"
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
b invalidPageWorkerLoop
# b blockWorkerLoop
# b PR_allocBuffer
# b PR_freeBuffer
# b PR_enqueue
b PR_fetchQueue
b PR_breakpoint_func
b PR_error_here
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
# b DecodeXLogRecord
