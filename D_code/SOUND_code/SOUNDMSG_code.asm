proc SoundMsg.AddInstrMessage uses esi edi,\
    unprocMsg

    mov     esi, [currTime]
    nop
    mov     esi, [unprocMsg]
    movzx   eax, byte[esi+UnprocessedMessage.instrNumber]
    imul    eax, sizeof.Instrument
    ;add     eax, instruments
    lea     edi, [instruments]
    add     edi, eax 
    ;push    eax
    ;push    eax
    invoke HeapAlloc, [hHeap], 8, sizeof.DoublyLinkedList
    ;pop     ecx
    ; ecx = instrument
    ; eax = msg node


    ; here I must add a new message as a InstrumentMessage struct and copy it
    ;mov     edx, [unprocMsg]
    ;add     edx, UnprocessedMessage.msgData
    ;mov     [eax+DoublyLinkedList.data], edx

    ; alloc memory of size sizeof.InstrumentMessage 
    ; copy data to this struct 
    ; move the data to doublylinkedlist

    push    eax     ; dll node
    invoke  HeapAlloc, [hHeap], 8, sizeof.InstrumentMessage
    push    eax     ; ptr instrumentMessage
    add     eax, InstrumentMessage.msgData
    add     esi, UnprocessedMessage.msgData
    stdcall Memory.memcpy, eax, esi, sizeof.MessageData
    pop     ecx     ; ptr instrumentMessage
    pop     eax     ; dll node 
    mov     [eax+DoublyLinkedList.data], ecx


    mov     ecx, [edi+Instrument.msgPollPtr]
    mov     [eax+DoublyLinkedList.next], ecx

    ; CAN BE REMOVED: THE ALLOCATED MEMORY IS INITIALIZED WITH ZERO
    mov     [eax+DoublyLinkedList.prev], LIST_NONE
    jecxz   .return
    mov     [ecx+DoublyLinkedList.prev], eax

.return:
    ;pop     ecx
    mov     [edi+Instrument.msgPollPtr], eax

    ret
endp

proc SoundMsg.RemoveInstrMessage,\
    instr, dllSoundMsg

    mov ecx, [instr]
    mov eax, [dllSoundMsg]
    cmp eax, [ecx+Instrument.msgPollPtr]
    je .isHead
    mov edx, [eax+DoublyLinkedList.prev]
    mov ecx, [eax+DoublyLinkedList.next]
    mov [edx+DoublyLinkedList.next], ecx
    push ecx
    ;cmp ecx, LIST_NONE
    ;je .return
    jecxz .return 
    mov  [ecx+DoublyLinkedList.prev], edx
    jmp .return

.isHead:
    mov edx, [eax+DoublyLinkedList.next]
    mov [ecx+Instrument.msgPollPtr], edx
    push edx
.return:

    ; free allocated memory for InstrumentMessage struct
    push   eax 
    add    eax, DoublyLinkedList.data 
    invoke HeapFree, [hHeap], 0, dword[eax]
    pop    eax 

    ; free allocated memory for DoublyLinkedList struct
    invoke HeapFree, [hHeap], 0, eax
    pop eax
    ret
endp

; horrible, purely horrible
proc SoundMsg.MessagePollAdd uses esi,\
    pTrack

    mov         esi, [pTrack]
    mov         ecx, [esi + Track.msgsCount]
.addMsgs:
    push        ecx 
    ;cmp         ecx, msgEnd
    ;je          .msgsAdded
    jecxz       .msgsAdded


    fld         [currTime]                                                  ; t
    mov         eax, [esi + Track.pUnprocMsgs]

    fld         [eax+UnprocessedMessage.msgData+MessageData.msgTrigger]         ; triggerTime, t
    FPU_CMP
    jae         .msgsAdded
    push        eax
    stdcall     SoundMsg.AddInstrMessage, eax
    pop         eax
    add         eax, sizeof.UnprocessedMessage
    mov         [esi + Track.pUnprocMsgs], eax

    pop         ecx 
    dec         ecx 
    jmp         .addMsgs
.msgsAdded:
    pop         ecx 
    mov         [esi + Track.msgsCount], ecx 

    ret
endp