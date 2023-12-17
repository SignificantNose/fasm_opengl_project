; routine for initializing the filter for the
; instument. depending on the value of 
; filterCoefType, data must be either the cutoff 
; frequency of the filter (const) or a pointer to 
; the LFO for cutoff frequency modulation (dynamic)
proc Filter.Initialize uses edi,\
    pInstrument, filterCoefType, data

    mov     edi, [pInstrument]
    invoke  HeapAlloc, [hHeap], 8, sizeof.InstrFilter
    mov     [edi + Instrument.filter], eax
    mov     edx, [data]

    cmp     [filterCoefType], FILTERCOEF_CONST 
    je      .const
    mov     [eax+InstrFilter.cutoffFreqLFO], edx
    jmp     .return 
.const:
    stdcall Filter.CalcButterworthCoeffs, edx, eax
.return:
    ret 
endp

; the routine recalculates the coefficients 
; that are used in the convolution of the 
; Butterworth filter. Returns the filter.
proc Filter.CalcButterworthCoeffs,\
    cutoff, filter
    
    mov     eax, [filter]

    fldpi               ; pi
    fmul    [cutoff]    ; pi*cutoff
    fidiv   [frDisc]    ; transFreq
    fld     st0         ; tF, tF
    fmul    st1, st0    ; tF, tF^2
    fld     st1         ; tF^2, tF, tF^2
    ; yikes
    mov     edx, 2.0
    push    edx

    fld     dword[esp]  ; 2, tF^2, tF, tF^2
    fld     st0         ; 2, 2, tF^2, tF, tF^2
    fmul    st2, st0    ; 2, 2, 2*tF^2, tF, tF^2
    fsqrt               ; sqrt(2), 2, 2*tF^2, tF, tF^2
    fmulp   st3, st0    ; 2, 2*tF^2, sqrt(2)*tF, tF^2
    fchs                ; -2, 2*tF^2, sqrt(2)*tF, tF^2
    fadd    st0, st1    ; a1, 2*tF^2, sqrt(2)*tF, tF^2
    fld1                ; 1, a1, b1, sqrt(2)*tF, tF^2
    fadd    st0, st4    ; 1+tF^2, a1, b1, sqrt(2)*tF, tF^2
    fld     st0         ; 1+tF^2, 1+tF^2, a1, b1, sqrt(2)*tF, tF^2
    fsub    st0, st4    ; a2, 1+tF^2, a1, b1, sqrt(2)*tF, tF^2
    fxch    st4         ; sqrt(2)*tF, 1+tF^2, a1, b1, a2, tF^2
    faddp               ; a0, a1, b1, a2, b0|b2
    fdiv    st1, st0    ; a0, a1F, b1, a2, b0|b2
    fdiv    st2, st0    ; a0, a1F, b1F, a2, b0|b2
    fdiv    st3, st0    ; a0, a1F, b1F, a2F, b0|b2
    fdivp   st4, st0    ; a1F, b1F, a2F, b0F|b2F
    fstp    [eax+InstrFilter.coeffs+ButterworthCoeffs.a1]    ; b1F, a2F, b0F|b2F
    fstp    [eax+InstrFilter.coeffs+ButterworthCoeffs.b1]    ; a2F, b0F|b2F
    fstp    [eax+InstrFilter.coeffs+ButterworthCoeffs.a2]    ; b0F|b2F
    fst     [eax+InstrFilter.coeffs+ButterworthCoeffs.b0]    ; b2F
    fstp    [eax+InstrFilter.coeffs+ButterworthCoeffs.b2]    

    ret
endp

; the routine takes the raw sample and calculates
; the processes sample value, shifting the stored 
; values in the filter array
proc Sound.FilterProcessChannel,\
    rawSample, coeffs, prevSamples
    
    mov     ecx, [coeffs]
    mov     eax, [prevSamples]

;    mov     edx, [eax+SampleArray.x4]
;    mov     [eax+SampleArray.x5], edx
;    mov     edx, [eax+SampleArray.x3]
;    mov     [eax+SampleArray.x4], edx
;    mov     edx, [eax+SampleArray.x2]
;    mov     [eax+SampleArray.x3], edx
;    mov     edx, [eax+SampleArray.x1]
;    mov     [eax+SampleArray.x2], edx
;    mov     edx, [eax+SampleArray.x0]
;    mov     [eax+SampleArray.x1], edx
    push    ecx     ; coeffs
    push    eax     ; prevSamples

    push    COUNTSHIFT*4
;    add     eax, SampleArray.x0     ; yikes
    push    eax
    add     eax, 4
    push    eax
    stdcall Memory.memcpy ;, eax+4, eax, COUNTSHIFT*4

    pop     eax     ; prevSamples
    pop     ecx     ; coeffs 

    mov     edx, [rawSample]
    mov     [eax+SampleArray.x0], edx

;    mov     edx, [eax+SampleArray.y4]
;    mov     [eax+SampleArray.y5], edx
;    mov     edx, [eax+SampleArray.y3]
;    mov     [eax+SampleArray.y4], edx
;    mov     edx, [eax+SampleArray.y2]
;    mov     [eax+SampleArray.y3], edx
;    mov     edx, [eax+SampleArray.y1]
;    mov     [eax+SampleArray.y2], edx
;    mov     edx, [eax+SampleArray.y0]
;    mov     [eax+SampleArray.y1], edx
    push    ecx
    push    eax

    push COUNTSHIFT*4
    add     eax, SampleArray.y0
    push    eax
    add     eax, 4
    push    eax
    stdcall Memory.memcpy ;, eax+SampleArray.y0+4, eax+SampleArray.y0, COUNTSHIFT*4
    

    pop     eax
    pop     ecx

    fld     [ecx+ButterworthCoeffs.b0]      ; b0
    fmul    [eax+SampleArray.x0]            ; b0*x0
    fld     [ecx+ButterworthCoeffs.b1]      ; b1, b0*x0
    fmul    [eax+SampleArray.x1]            ; b1*x1, b0*x0
    fld     [ecx+ButterworthCoeffs.b2]      ; b2, b1*x2, b0*x0
    fmul    [eax+SampleArray.x2]            ; b2*x2, b1*x1, b0*x0
    faddp                                   ; advanceSum, b0*x0
    faddp                                   ; advanceSum
    fld     [ecx+ButterworthCoeffs.a1]      ; a1, advanceSum
    fmul    [eax+SampleArray.y1]            ; a1*y1, advanceSum
    fld     [ecx+ButterworthCoeffs.a2]      ; a2, a1*y1, advanceSum
    fmul    [eax+SampleArray.y2]            ; a2*y2, a1*y1, advanceSum
    faddp                                   ; a2*y2+a1*y1, advanceSum
    fsubp                                   ; procSample
    fstp    [eax+SampleArray.y0]

    mov     eax, [eax+SampleArray.y0]
    ret
endp

; routine purely for LFO to recalculate 
; previous samples. Reasoning:
; without recalculating the previous samples
; the filter sounds rather dissapointing. 
; I found it possible that the filter uses
; new coefficients, but old sample values, so 
; the result is not the expected one. That's why
; when the cutoff frequency is changed, the 
; coefficients are recalculated, and so are the 
; previous sample values 
;
; for now: the difference in incomprehensible

proc Sound.FilterRecalculatePrev,\
    coeffs, prevSamples

    mov     edx, [coeffs]
    mov     eax, [prevSamples]


    ; start from the earlier sample
    fldz                            ; 0
    fst     [eax+SampleArray.y079]    ; 0
    fstp    [eax+SampleArray.y080]    ;
    add     eax, SampleArray.x078
    mov     ecx, COUNTSHIFT-1
.looper:
    fld     [edx+ButterworthCoeffs.b0]      ; b0
    fmul    [eax+SampleArray.x0]            ; b0*x0
    fld     [edx+ButterworthCoeffs.b1]      ; b1, b0*x0
    fmul    [eax+SampleArray.x1]            ; b1*x1, b0*x0
    fld     [edx+ButterworthCoeffs.b2]      ; b2, b1*x2, b0*x0
    fmul    [eax+SampleArray.x2]            ; b2*x2, b1*x1, b0*x0
    faddp                                   ; advanceSum, b0*x0
    faddp                                   ; advanceSum
    fld     [edx+ButterworthCoeffs.a1]      ; a1, advanceSum
    fmul    [eax+SampleArray.y1]            ; a1*y1, advanceSum
    fld     [edx+ButterworthCoeffs.a2]      ; a2, a1*y1, advanceSum
    fmul    [eax+SampleArray.y2]            ; a2*y2, a1*y1, advanceSum
    faddp                                   ; a2*y2+a1*y1, advanceSum
    fsubp                                   ; procSample
    fstp    [eax+SampleArray.y0]

    sub     eax, 4
    loop    .looper

    ret
endp


; routine for applying the filter to the
; samples leftS and rightS. returns the 
; values of the samples with the applied
; filter in edx (left sample) and eax 
; (right sample) registers
proc Filter.ApplyToSamples uses esi,\
    leftS, rightS, pInstrument

    mov     esi, [pInstrument]
    mov     esi, [esi + Instrument.filter]

    mov     ecx, [ecx + InstrFilter.cutoffFreqLFO]
    jecxz   .noFilterLFO
    stdcall LFO.ModulateCutoffFreq, ecx, [pInstrument]

.noFilterLFO:
    ; mov     eax, [esi + InstrFilter.coeffs]
    mov     edx, esi 
    add     edx, InstrFilter.leftSamples
    ; mov     edx, [esi + InstrFilter.leftSamples]
    mov     eax, esi 
    add     eax, InstrFilter.coeffs

    push    eax     ; coeffs
    stdcall Sound.FilterProcessChannel, [leftS], eax, edx ;, sample, coeffs, prevSamples
    pop     edx     ; coeffs
    push    eax     ; left sample

    ; mov     eax, [esi + InstrFilter.rightSamples]
    mov     eax, esi 
    add     eax, InstrFilter.rightSamples
    stdcall Sound.FilterProcessChannel, [rightS], edx, eax 
    
    pop     edx     ; left sample

    ret 
endp

; routine for clearing filter so that
; the next track doesn't get affected by it
proc Filter.ClearFilter uses edi,\
    pFilter

    mov     edx, [pFilter]
    lea     edi, [edx + InstrFilter.leftSamples]
    mov     ecx, sizeof.SampleArray/4
    push    ecx     ; NofSamples
    xor     eax, eax
    rep     stosd 
    pop     ecx     ; NofSamples
    lea     edi, [edx + InstrFilter.rightSamples]
    rep     stosd 

    ret 
endp 