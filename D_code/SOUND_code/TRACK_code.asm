; routine for generating a sound buffer from
; a Track struct that contains all the 
; necessary data, that is: the length of the 
; track and the message poll of the track.
; returns the buffer (eax) and the duration
; of the track (edx)
proc Track.GenerateTrack uses esi edi,\
    pPackedTrack

    locals
        BufferObject     IDirectSoundBuffer8
        szBuffer         dd     ?
        nextMsgTrigger   dd     0.0

        pTrackInstrList  dd     ?
    endl 

; the list will contain copies of instruments. reason:
; it must be a little faster, as there will be n times
; less memory access if it was implemented with the use
; of pointers. moreover, Instrument struct data does not
; change.
;
; upd: problem; Instrument struct does change in course of 
; adding new messages. that way, the instrument list will 
; contain pointers to instruments 
    invoke      HeapAlloc, [hHeap], 8, sizeof.TrackInstrumentList
    mov         [pTrackInstrList], eax 
    xchg        edi, eax
    invoke      HeapAlloc, [hHeap], 8, sizeof.InstrDefiner*instrumentsCount
    mov         [edi + TrackInstrumentList.InstrDefinerArray], eax 
    
    ; lea         edx, [instrListCount]
    ; push        eax     ; pInstrList
    ; push        edx     ; pInstrListCount
    ; push        eax     ; pInstrList
    ; push        edx     ; pInstrListCount 

    mov         esi, [pPackedTrack]
    stdcall     SoundMsg.FormMessageStack, esi, edi 
    stdcall     Sequencer.AddAllMessages, esi, edi 

    ; calculating the amount of data needed to
    ; be allocated for the buffer
    fld         [esi + PackedTrack.trackDuration]     
    mov         eax, 2*FRDISC_VALUE*2
    push        eax 
    fimul       dword[esp]
    pop         eax 
    fistp       dword[szBuffer]

    mov         edi, [szBuffer]
    mov         [dsbd.dwBufferBytes], edi
    
    lea         eax, [BufferObject]
    cominvk     dsc, CreateSoundBuffer, dsbd, eax, NULL
    cominvk     BufferObject, Lock, 0, edi, ptrPart1, bytesPart1, ptrPart2, bytesPart2, 0


    ; avoiding division by zero in pitch modulation        
    mov         [timeValue], 1
    xchg        ecx, edi 
    shr         ecx, 2
    mov         edi, [ptrPart1]
.looper:
    push        ecx


    fild        [timeValue]     ; timeCount 
    fidiv       [frDisc]        ; time
    fst         [currTime]
    fld         [nextMsgTrigger]    ; nextTrigger, time
    FPU_CMP
    ja          @F
    stdcall     SoundMsg.MessagePollAdd, esi
    mov         [nextMsgTrigger], eax
@@:
    nop
    stdcall     Sound.PlayMsgList, [pTrackInstrList]
    stosw
    ror         eax, 16
    stosw   

    inc         [timeValue]
    pop         ecx
    loop        .looper

    mov         edi, [pTrackInstrList]
    stdcall     Sound.ClearInstruments, edi 
    mov         eax, [edi + TrackInstrumentList.InstrDefinerArray]
    invoke      HeapFree, [hHeap], 0, eax 
    invoke      HeapFree, [hHeap], 0, edi 

    cominvk     BufferObject, Unlock, [ptrPart1], [bytesPart1], [ptrPart2], [bytesPart2]

    cominvk     BufferObject, QueryInterface, IID_IDirectSoundNotify8, lpDSNotify 
    cominvk     lpDSNotify, SetNotificationPositions, 1, PositionNotify
    cominvk     lpDSNotify, Release

    mov         eax, [BufferObject]
    mov         edx, [esi + PackedTrack.trackDuration]
    ; invoke  HeapAlloc, [hHeap], 8, sizeof.Track
    ; mov     edx, [BufferObject]
    ; mov     [eax + Track.buffer], edx 
    ; mov     edx, [esi + PackedTrack.trackDuration]
    ; mov     [eax + Track.trackDuration], edx 

    ret
endp 

; routine for adding the instrument for a current 
; unprocessed message to a track instrument list
; in case the instrument hadn't been added yet 
proc Track.AddTrackInstrList uses esi,\
    pTrackInstrList, pUnprocMsg

    mov     esi, [pTrackInstrList]
    mov     ecx, [esi + TrackInstrumentList.InstrCount]
    mov     edx, [esi + TrackInstrumentList.InstrDefinerArray]
    mov     eax, [pUnprocMsg]
    movzx   eax, byte[eax + UnprocessedMessage.instrNumber]

    jecxz   .add
.looper:
    cmp     byte[edx + InstrDefiner.instrNum], al
    je      .return 
    add     edx, sizeof.InstrDefiner 
    loop    .looper 
.add:
    inc     [esi + TrackInstrumentList.InstrCount]
    mov     [edx + InstrDefiner.instrNum], al


    imul    eax, sizeof.Instrument
    lea     esi, [instruments]
    add     esi, eax 

    mov     [edx + InstrDefiner.pInstrument], esi 

.return:
    ret 
endp 