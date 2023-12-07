
; routine for defining starting time of sequencer
; (relatively to the current time):
; calculates the elapsed time, so that the 
; sequencer starts playing [startTime] seconds
; after the current time
proc Sound.StartTimeSequencer,\
    startTime

    mov     eax, seqMain
    fld     [startTime]                     ; startTime
    fstp    [eax+Sequencer.timeElapsed]     ; 
    mov     word[eax+Sequencer.currentBeat], -1

    ret
endp


; routine for adding another instrument to the sequencer.
; Takes the message values for the sequencer and the 
; pattern of the message. Adds the sequencer instrument
; to the main sequencer
proc Sound.AddSequencer,\
    soundMsg, pattern
    
; creating new message node
    invoke  HeapAlloc, [hHeap], 8, sizeof.DoublyLinkedList
    mov     ecx, [soundMsg]
    mov     [eax+DoublyLinkedList.data], ecx

    mov     ecx, [seqMain+Sequencer.msgListHead]
    mov     [eax+DoublyLinkedList.next], ecx
    ;cmp     ecx, LIST_NONE
    ;je      .finishMessage
    jcxz    .finishMessage
    mov     [ecx+DoublyLinkedList.prev], eax
.finishMessage:
    mov     [seqMain+Sequencer.msgListHead], eax

; creating new pattern node
    invoke  HeapAlloc, [hHeap], 8, sizeof.DoublyLinkedList
    mov     ecx, [pattern]
    mov     [eax+DoublyLinkedList.data], ecx

    mov     ecx, [seqMain+Sequencer.patternListHead]
    mov     [eax+DoublyLinkedList.next], ecx

    ;cmp     ecx, LIST_NONE
    ;je      .finishPattern
    jcxz    .finishPattern
    mov     [ecx+DoublyLinkedList.prev], eax
.finishPattern:
    mov     [seqMain+Sequencer.patternListHead], eax

    ret
endp

; must be rewritten
;proc Sound.CreateMsgCopy uses edi esi,\
;    soundMsg
;
;    invoke  HeapAlloc, [hHeap], 8, sizeof.Message
;    ;push    eax
;    mov     edi, eax
;    mov     esi, [soundMsg]
;    mov     ecx, sizeof.Message
;;.looper:
;    ;movsb   
;    ;loop .looper
;    rep movsb   
;    ;pop     eax
;
;    ret
;endp



; probably will not work: new message logic
proc Sound.UpdateSequencer

    ; RESOLVE ONE SEC

    mov     ecx, seqMain
    fld     [ecx+Sequencer.timeElapsed]     ; tElapsed
    fsub    [oneSec]                        ; newTime

    fld     st0                             ; newTime, newTime
    ;fld     [ecx+Sequencer.timeOneBeat]     ; dt, newTime, newTime
    fldz                                    ; 0, newTime, newTime
    FPU_CMP                                 ; newTime
    ;jmp     .return
    jbe      .return
; adding another sequence of notes instead


    ;fsub    [ecx+Sequencer.timeOneBeat]     ; finishTime
    fadd    [ecx+Sequencer.timeOneBeat]      ; finishTime

    mov     ax, word[ecx+Sequencer.currentBeat]
    inc     ax
    xor     edx, edx
    div     word[ecx+Sequencer.totalBeats] 
    ; now (e)dx has the current beat
    mov     word[ecx+Sequencer.currentBeat], dx




;goal: to copy a message in case it corresponds to the pattern and poll it

    push    ecx

    mov     eax, [ecx+Sequencer.patternListHead]
    mov     ecx, [ecx+Sequencer.msgListHead]

.looper:
    ;cmp     ecx, LIST_NONE
    ;je      .msgsEnded
    jcxz    .msgsEnded
    push    ecx
    push    eax
    push    edx

    mov     eax, [eax+DoublyLinkedList.data]
    bt      eax, edx
    jnc     .notNewMessage
    ;mov     eax, [eax+DoublyLinkedList.data]
    ;stdcall Sound.CreateMsgCopy, eax
    stdcall  Sound.CreateMsgCopy, [ecx+DoublyLinkedList.data]

    mov      ecx, [currTime]
    mov      [eax+Message.msgTrigger], ecx
    stdcall  Sound.NewMessage, eax

.notNewMessage:

    pop     edx
    pop     eax
    pop     ecx
    mov     eax, [eax+DoublyLinkedList.next]
    mov     ecx, [ecx+DoublyLinkedList.next]
    jmp     .looper

.msgsEnded:
    pop     ecx
    
.return:
    fstp    [ecx+Sequencer.timeElapsed]     ;
    ret
endp