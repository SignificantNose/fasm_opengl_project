; routine for generating a buffer with given
; delay and gain values. returns the pointer
; to the reverberator in eax register
;
; WARNING: this routine initializes reverberator 
; with 5 buffers with different delay and gain 
; values
proc Reverb.GenerateReverberator uses esi edi,\
    delaySeconds, gain

    invoke  HeapAlloc, [hHeap], 8, sizeof.Reverberator
    push    eax     ; reverberator

    invoke  HeapAlloc, [hHeap], 8, sizeof.ReverbBuffer*REVERB_COUNTBUFFERS
    pop     edx     ; reverberator
    push    edx     ; reverberator 
    mov     [edx + Reverberator.arrOfBuffers], eax
    mov     [edx + Reverberator.countBuffers], REVERB_COUNTBUFFERS
    
    mov     ecx, REVERB_COUNTBUFFERS
    mov     esi, Reverb.DelayMultipliers
    mov     edi, Reverb.GainMultipliers
    xchg    edx, eax 

; looping through each reverb buffer and initializing values for them
.looper:
    push    ecx     ; counter
    push    edx     ; ReverbBuffer

    fld     dword[esi]          ; delayMult
    fmul    [delaySeconds]      ; delay
    fimul   [frDisc]            ; delayInSamples
    fistp   dword[edx + ReverbBuffer.delayInSamples]

    fld     dword[edi]          ; gainMult
    fmul    [gain]              ; gain
    fstp    dword[edx + ReverbBuffer.gain]

    mov     eax, [edx + ReverbBuffer.delayInSamples]
    shl     eax, 2
    push    eax     ; bytesAlloc


    push    edx     ; ReverbBuffer
    invoke  HeapAlloc, [hHeap], 8, eax
    pop     edx     ; ReverbBuffer

    pop     ecx     ; bytesAlloc

    push    eax     ; leftSamples
    invoke  HeapAlloc, [hHeap], 8, ecx 
    pop     ecx     ; leftSamples


    pop     edx     ; ReverbBuffer
    mov     [edx + ReverbBuffer.dataLeft], eax
    mov     [edx + ReverbBuffer.dataRight], ecx
    pop     ecx     ; counter
    add     edx, sizeof.ReverbBuffer
    add     esi, 4
    add     edi, 4
    loop    .looper 

    pop     eax

    ret 
endp


; routine for applying reverb effect to the
; leftS and rightS samples using reverberator.
; returns samples with reverb applied in edx 
; (left sample) and eax (right sample) registers
proc Reverb.ApplyToSamples uses esi,\
    leftS, rightS, reverberator

    locals 
        resultLeft      dd      ?
        resultRight     dd      ?
    endl

    mov     eax, [leftS]
    mov     [resultLeft], eax

    mov     eax, [rightS]
    mov     [resultRight], eax

    mov     esi, [reverberator]
    mov     ecx, [esi + Reverberator.countBuffers]
    push    ecx     ; countBuffers

    mov     esi, [esi + Reverberator.arrOfBuffers]

.looperProcessSample:
    push    ecx     ; iterator

    stdcall Reverb.ProcessSample, esi, true
    push    eax     ; leftSample
    fld     dword[esp]
    fadd    [resultLeft]
    fstp    [resultLeft]
    pop     eax     ; leftSample

    stdcall Reverb.ProcessSample, esi, false
    push    eax     ; rightSample
    fld     dword[esp]
    fadd    [resultRight]
    fstp    [resultRight]
    pop     eax     ; rightSample

    add     esi, sizeof.ReverbBuffer
    pop     ecx     ; iterator
    loop    .looperProcessSample 


    pop     ecx     ; countBuffers
.looperShiftIndex:
    push    ecx     ; iterator
    sub     esi, sizeof.ReverbBuffer
    stdcall Reverb.ShiftIndex, esi, [resultLeft], [resultRight]

    pop     ecx     ; iterator 
    loop    .looperShiftIndex 
;PROBLEM IS HERE

    mov     edx, [resultLeft]
    mov     eax, [resultRight]

    ret 
endp 

; routine for applying a reverb process by
; acquiring reverbBuffer's contribution to
; forming a current sample for reverb
proc Reverb.ProcessSample uses edi ,\
    reverbBuffer, isLeft

    mov     edi, [reverbBuffer]
    mov     ecx, [edi + ReverbBuffer.dataRight]
    cmp     [isLeft], false
    je      .right
    mov     ecx, [edi + ReverbBuffer.dataLeft]
.right:
    mov     eax, [edi + ReverbBuffer.index] 
    imul    eax, 4
    add     ecx, eax

    fld     dword[ecx]                      ; sample
    fmul    dword[edi + ReverbBuffer.gain]  ; sample * gain
    push    eax 
    fstp    dword[esp]
    pop     eax 

    ret
endp

; routine for saving the value in the reverb buffer
; and shifting the index of the buffer
proc Reverb.ShiftIndex uses edi,\
    reverbBuffer, sampleLeft, sampleRight


    ; mov     edi, [reverbBuffer]

; acquiring the current offset in the array



    mov     edi, [reverbBuffer]
    mov     eax, [edi + ReverbBuffer.index]
    imul    eax, 4                          ; data array offset
    
    mov     edx, [edi + ReverbBuffer.dataLeft]
    add     edx, eax
    mov     ecx, [sampleLeft]
    mov     dword[edx], ecx 
    
    mov     edx, [edi + ReverbBuffer.dataRight]
    add     edx, eax 
    mov     ecx, [sampleRight]
    mov     dword[edx], ecx

    mov     eax, [edi + ReverbBuffer.index]
    inc     eax 
    xor     edx, edx
    idiv    dword[edi + ReverbBuffer.delayInSamples]
    mov     [edi + ReverbBuffer.index], edx 


    ret 
endp