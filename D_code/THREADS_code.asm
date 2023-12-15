proc Threads.InitEventsAndThreads

    invoke      CreateEvent,\
        NULL,\      ; default security attributes
        true,\      ; is manually reset
        false, \    ; initial state = reset
        NULL        ; unnamed
    mov         [hEventNotify], eax
    mov         [PositionNotify + DSBPOSITIONNOTIFY.hEventNotify], eax 

    invoke      CreateEvent,\
        NULL,\
        true,\
        false,\
        NULL
    mov         [hEventTerminate], eax 


    invoke      CreateThread,\
        NULL,\              ; default security attributes
        0,\                 ; default stack size
        Threads.MainThreadProc,\  
        NULL,\              ; no thread parameters
        0,\                 ; default startup flags 
        dwThreadID          

    ret 
endp

proc Threads.MainThreadProc uses esi,\
    param

    mov     esi, Scenes.ArrMain
    mov     ecx, Scenes.ArrMainCount

    push    ecx
.looper:
    invoke  WaitForMultipleObjects, Threads.EventsCount, Threads.EventHandles, false, INFINITE

; jesus, what is it. stop    
; can't think of a better debug option now
    pop     ecx 
    push    ecx 
    cmp     ecx, Scenes.ArrMainCount
    je      @F
    cominvk PlayBuffer, Stop        ; MAYBE NOT???
@@:
; p.s. debug option

    JumpIf  WAIT_OBJECT_0 + 1, .Exit 
    stdcall Debug.PrintThreadInfo
    invoke  ResetEvent, [hEventNotify]

    ; scene switch 
    pop     ecx 
    jecxz   .Exit
    dec     ecx 
    push    ecx 
    mov     [currentScene], esi
    mov     eax, [esi + Scene.soundtrack + Track.buffer]
    mov     [PlayBuffer], eax 
    cominvk PlayBuffer, Play, 0, 0, 0

    ; scene switch end
    add     esi, sizeof.Scene
    jmp     .looper 

.Exit:
    pop     ecx

    ret
endp