dwThreadID      dd      ?

Threads.EventHandles:
    hEventNotify    dd      ?
    hEventTerminate dd      ?
Threads.EventsCount = ($-Threads.EventHandles)/4