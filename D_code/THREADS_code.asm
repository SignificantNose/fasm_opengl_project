proc Threads.MainThreadProc,\
    param

.looper:

    ;invoke  WaitForSingleObject, [hEventNotify], INFINITE
    invoke  WaitForMultipleObjects, Threads.EventsCount, Threads.EventHandles, false, INFINITE
    JumpIf  WAIT_OBJECT_0 + 1, .Exit 
    stdcall Debug.PrintThreadInfo
    invoke  ResetEvent, [hEventNotify]
    jmp     .looper 

.Exit:

    ret
endp