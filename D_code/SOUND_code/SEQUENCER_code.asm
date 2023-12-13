; routine for adding another instrument to the sequencer.
; takes the message values for the sequencer and the 
; pattern of the message. Adds the sequencer instrument
; to the main sequencer
; DEPRECATED: multiple sequencers allow for more flexibility
; unlike this approach
proc Sequencer.AddMsgPattern,\
    soundMsg, pattern
    
; creating new message node
    invoke  HeapAlloc, [hHeap], 8, sizeof.DoublyLinkedList
    mov     ecx, [soundMsg]
    mov     [eax+DoublyLinkedList.data], ecx        

    mov     ecx, [seqMain+Sequencer.msgListHead]
    mov     [eax+DoublyLinkedList.next], ecx
    ;cmp     ecx, LIST_NONE
    ;je      .finishMessage
    jecxz   .finishMessage
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
    jecxz   .finishPattern
    mov     [ecx+DoublyLinkedList.prev], eax
.finishPattern:
    mov     [seqMain+Sequencer.patternListHead], eax

    ret
endp


; routine for adding messages from all the sequencers
; pSequencer points at to the pPackedTrack message stack
proc Sequencer.AddAllMessages uses esi edi,\
    pPackedTrack

    mov     edi, [pPackedTrack]

    mov     esi, [edi + PackedTrack.pSequencers]
    nop 
    mov     ecx, [edi + PackedTrack.SequencersCount]
    
    ; if ecx is zero, then it will loop at
    ; least once, which is not the desired 
    ; result. moreover, the routine for adding
    ; messages for sequencer will be called for
    ; SOME data that is not a sequencer
    jecxz   .return 
.looper:
    push    ecx 

    stdcall Sequencer.AddMessages, esi, edi
    add     esi, sizeof.Sequencer

    pop     ecx 
    loop    .looper 

.return:
    ret 
endp 

; routine for adding the messages of a separate 
; sequencer to the message stack of pPackedTrack 
proc Sequencer.AddMessages uses esi edi,\
    pSequencer, pPackedTrack

    locals  
        currentTime     dd      ?
        timeIncrement   dd      ?
        timeFinal       dd      ?

        totalSteps      dw      ?
        currentStep     dw      0
    endl

    mov     esi, [pSequencer]
    mov     edi, [pPackedTrack]

; acquiring final time 
    mov     edx, [edi + PackedTrack.trackDuration]
    mov     [timeFinal], edx

; acquiring start time and setting it as the current
    mov     eax, [esi + Sequencer.startTime]
    mov     [currentTime], eax 

; calculating step increment and the total 
; amount of steps per cycle
    mov     eax, 60.0
    push    eax     ; 60.0
    fld     dword[esp]                          ; 60.0
    fld     dword[esi + Sequencer.tempo]        ; tempo, 60.0
    movzx   eax, byte[esi + Sequencer.steps]
    push    eax     ; steps
    fimul   dword[esp]                          ; tempo*steps, 60.0
    fdivp                                       ; timeInc
    fstp    [timeIncrement]
    pop     eax     ; steps 
    mov     dl, byte[esi + Sequencer.bars]
    imul    dl 
    mov     [totalSteps], ax 
    pop     eax     ; 60.0

.looper:
    fld     [currentTime]       ; t
    fld     [timeFinal]         ; tFinal, t
    FPU_CMP     
    jbe     .return 


    mov     ecx, [esi + Sequencer.seqMsgCount]
    jecxz   .return 

    movzx   eax, [currentStep]
    mov     edx, [esi + Sequencer.seqMsgArray]

.addingMsgs:
    push    ecx 
    push    edx 
    push    eax 

    bt      dword[edx + SeqMessage.pattern], eax
    jnc     .notNewMessage


    mov     eax, [edx + SeqMessage.msgData]
    mov     edx, [currentTime]
    mov     [eax + UnprocessedMessage.msgData + MessageData.msgTrigger], edx
    push    eax 
    invoke  HeapAlloc, [hHeap], 8, sizeof.UnprocessedMessage
    pop     edx 
    push    eax 
    stdcall Memory.memcpy, eax, edx, sizeof.UnprocessedMessage
    pop     eax 
    stdcall SoundMsg.AddStack, edi, eax 


.notNewMessage:
    pop     eax 
    pop     edx 
    pop     ecx 

    add     edx, sizeof.SeqMessage
    loop    .addingMsgs

    ; inc currStep and div  
    inc     ax 
    xor     dx, dx 
    mov     cx, word[totalSteps] 
    idiv    cx
    mov     [currentStep], dx 
    


    fld     [currentTime]
    fadd    [timeIncrement]
    fstp    [currentTime]
    jmp     .looper

.return:
    ret 
endp