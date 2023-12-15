proc SoundMsg.AddInstrMessage uses esi edi,\
    unprocMsg

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

proc SoundMsg.MessagePollAdd uses esi edi,\
    pPackedTrack

    mov     esi, [pPackedTrack]

.looper:
    mov     edi, [esi + PackedTrack.pMsgStack]
    cmp     edi, 0
    je      .stackEmpty

    mov     ecx, [edi + SortedStack.data]
    mov     eax, [ecx + UnprocessedMessage.msgData + MessageData.msgTrigger]
    fld     [currTime]                                                              ; time
    push    eax 
    fld     dword[esp]                                                              ; msgTrigger, time
    pop     eax 
    FPU_CMP 
    ja      .endLoop
    stdcall SoundMsg.AddInstrMessage, ecx

    mov     ecx, [edi + SortedStack.next]
    push    ecx 
    invoke  HeapFree, [hHeap], 0, edi
    pop     ecx 
    mov     [esi + PackedTrack.pMsgStack], ecx 


    jmp     .looper

.stackEmpty:
    mov     eax, 1000000000.0


.endLoop:

; while track.pStack.triggerTime<=currTime:
;   POP message to the instrument
;   move to the next
; return track.pStack.triggerTime

    ret
endp


proc SoundMsg.FormMessageStack uses esi edi,\
    pPackedTrack

    mov     edi, [pPackedTrack]
    mov     [edi + PackedTrack.pMsgStack], 0

    mov     esi, [edi + PackedTrack.pMsgsStart]
    mov     ecx, [edi + PackedTrack.MsgsCount]

    jecxz   .return 

.looper:
    push    ecx

    stdcall SoundMsg.AddStack, edi, esi 
    add     esi, sizeof.UnprocessedMessage

    pop     ecx 
    loop    .looper 

.return:
    ret 
endp


; the 3-case situation is not so convenient for,
; adding new messages, but IS convenient for a 
; stack to not have a head element
proc SoundMsg.AddStack uses esi edi,\
    pPackedTrack, pUnprocMsg
    
    mov     edi, [pPackedTrack]
    mov     esi, [pUnprocMsg]

    invoke  HeapAlloc, [hHeap], 8, sizeof.SortedStack
    mov     [eax+SortedStack.data], esi
    push    eax 

    mov     ecx, [edi + PackedTrack.pMsgStack]
    ;jecxnz  .notEmpty
    cmp     ecx, 0
    jnz     .notEmpty

    ; make not empty and jump
    pop     eax 
    mov     [edi + PackedTrack.pMsgStack], eax 
    jmp     .return
.notEmpty:
    mov     edx, [ecx + SortedStack.data]
    ;mov     edx, [edx + UnprocessedMessage.msgData + MessageData.msgTrigger]
    ;cmp     [esi + UnprocessedMessage.msgData + MessageData.msgTrigger]
    fld     dword[edx + UnprocessedMessage.msgData + MessageData.msgTrigger]        ; topTrigger
    fld     dword[esi + UnprocessedMessage.msgData + MessageData.msgTrigger]        ; newTrigger, topTrigger
    FPU_CMP
    ja      .searchPlace
    
    ; make not empty and set next and jump
    pop     eax 
    mov     [eax + SortedStack.next], ecx
    mov     [edi + PackedTrack.pMsgStack], eax 
    jmp     .return 

.searchPlace:
    ; prev = edx 
    mov     edx, ecx 
.looper:
    mov     ecx, [ecx + SortedStack.next]
    jecxz .endLoop

    mov     eax, [ecx + SortedStack.data]
    fld     dword[eax + UnprocessedMessage.msgData + MessageData.msgTrigger]        ; currTrigger
    fld     dword[esi + UnprocessedMessage.msgData + MessageData.msgTrigger]        ; newTrigger, currTrigger
    FPU_CMP
    jbe     .endLoop

    mov     edx, ecx 
    jmp     .looper
.endLoop:

    pop     eax 
    mov     [edx + SortedStack.next], eax 
    mov     [eax + SortedStack.next], ecx


; temp = alloc(sizeof.SortedStack)
; temp.data = pUnprocMsg 
; //temp.next = null
;
; if track.pMsgStack == null:  
;   track.pMsgStack = temp
; else
; if track.pMsgStack.data.triggerTime>=temp.data.triggerTime:
;   temp.next = track.pMsgStack
;   track.pMsgStack = temp
; else:
;   prev = null  // not null, something else
;   while (currElem!=null && temp.data.triggerTime>currElem.data.triggerTime):
;       prev = currElem
;       currElem = currElem.next
;   temp.next = currElem
;   prev.next = temp

.return:
    ret
endp