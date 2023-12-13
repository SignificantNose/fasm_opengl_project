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
    endl 


    mov         esi, [pPackedTrack]
    stdcall     SoundMsg.FormMessageStack, esi 
    stdcall     Sequencer.AddAllMessages, esi

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

    stdcall     Sound.PlayMsgList
    stosw
    ror         eax, 16
    stosw   

    inc         [timeValue]
    pop         ecx
    loop .looper

    stdcall     Sound.ClearInstruments

    cominvk BufferObject, Unlock, [ptrPart1], [bytesPart1], [ptrPart2], [bytesPart2]

    mov     eax, [BufferObject]
    mov     edx, [esi + PackedTrack.trackDuration]
    ; invoke  HeapAlloc, [hHeap], 8, sizeof.Track
    ; mov     edx, [BufferObject]
    ; mov     [eax + Track.buffer], edx 
    ; mov     edx, [esi + PackedTrack.trackDuration]
    ; mov     [eax + Track.trackDuration], edx 

    ret
endp 