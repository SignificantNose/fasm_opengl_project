proc Sound.PowXY,\  
    x,y

    fld     [y]     ; y
    fld     [x]     ; x, y
    fyl2x           ; y*log2(x)
    fld     st0     ; y*log2(x), y*log2(x)
    frndint         ; round, y*log2(x)
    fsub    st1, st0    ; round, realPart
    fxch    st1     ; realPart, round
    f2xm1           ; e-1, round
    fld1            ; 1, e-1, round
    faddp           ; e, round
    fscale          ; x^y, round   
    fstp    st1     ; x^y
    push_st0        
    pop     eax

    ret
endp

proc Sound.GetOscSamples,\
    pOsc, freq, triggerTime
    locals 
        step        dd      ?
        NumTwo      dd      ?
        NumTwelve   dd      ?
        left        dd      ?
        right       dd      ?
        leftMul     dd      ?
        rightMul    dd      ?
    endl

    ; hate it, but for now let it be this way
    mov     ecx, [pOsc]
    ; get cutofffreqlfo and cmp with 0 to make sure that it's present
    ; eax = Sound.LFOGetValue
    ; freq*=eax
    mov     eax, [ecx+Oscillator.pitchLFO]
    cmp     eax, 0
    je      .noPitchLFO
    push    ecx
    ;stdcall Sound.LFOGetValue, eax, [triggerTime]
    mov     eax, 1.1
    pop     ecx
    fld     [freq]
    push    eax 
    fmul    dword[esp]
    pop     eax 
    fstp    [freq]
    



.noPitchLFO:
    ; after cahnging the LFO, unison can be applied

    movzx   eax, byte[ecx+Oscillator.oscType]
    mov     edx, [ecx+Oscillator.detune]

    cmp     edx, 0
    je      .noUnison


    movzx   ecx, byte[ecx+Oscillator.voices]
    mov     [NumTwo], 2.0
    mov     [NumTwelve], 12.0
    mov     [left], 0.0
    mov     [right], 0.0

    push    edx
    fld     dword[esp]      ; detune
    fmul    [NumTwo]           ; 2*detune
    push    ecx
    fild    dword[esp]      ; voices, 2*detune
    fld1                    ; 1, voices, 2*detune
    fsubp                   ; voices-1, 2*detune
    fdivp                   ; step
    fstp    [step]

    pop     ecx
    ;fld     dword[esp]      ; detune 
    ;fchs                    ; -detune
    ;fstp    dword[esp]    
    pop     eax
    ; eax keeps track of the current detune

.looper:
    push    ecx
    push    eax

    push    eax
    fld     dword[esp]      ; currDetune
    fdiv    [NumTwelve]     ; detune/12
    fstp    dword[esp]
    pop     eax
    stdcall Sound.PowXY, 2.0, eax
    push    eax
    fld     dword[esp]      ; detunator
    fmul    [freq]          ; tune
    fstp    dword[esp]
    pop     eax

    mov     ecx, [pOsc]
    movzx   ecx, [ecx+Oscillator.oscType]
    stdcall Sound.GenSample, ecx, eax

    fld1                    ; 1
    fld     dword[esp]      ; currDetune, 1
    fdiv    [NumTwo]        ; panPhase, 1
    fld     st0             ; panPhase, panPhase, 1
    fldz                    ; 0, panPhase, panPhase, 1
    FPU_CMP                 ; panPhase, 1
    ja      @F
    ; positive
    ; right = 1, left = 1 - panPhase
    fsubp                   ; 1-panPhase
    fstp    [rightMul]      ;
    fld1                    ; 1
    fstp    [leftMul]       ;
    jmp     .saveSample

@@:
    ; negative
    ; left = 1, right = 1 + panPhase
    faddp                   ; 1+panPhase
    fstp    [leftMul]       ;
    fld1                    ; 1
    fstp    [rightMul]      ;

.saveSample:
    push    eax
    fld     dword[esp]      ; sample
    fld     st0             ; sample, sample
    fmul    [leftMul]       ; leftSample, sample
    fadd    [left]          ; leftNew, sample
    fstp    [left]          ; sample
    fmul    [rightMul]      ; rightSample
    fadd    [right]         ; rightNew
    fstp    [right]         ;   
    pop     eax


    fld     dword[esp]      ; currStep
    fsub    [step]          ; newStep
    fstp    dword[esp]      ;
    pop     eax
    pop     ecx
    loop .looper

    mov     ecx, [pOsc]
    movzx   ecx, byte[ecx+Oscillator.voices]
    push    ecx
    fld     [left]      ; left
    fidiv   dword[esp]  ; finalLeft
    push    edx
    fstp    dword[esp]  
    pop     edx
    fld     [right]     ; right
    fidiv   dword[esp]  ; finalRight
    fstp    dword[esp]
    pop     eax

    jmp .return
.noUnison:

    stdcall Sound.GenSample, eax, [freq]
    ; returns float
    mov     edx, eax

.return:

    ret
endp

; the routine recalculates the coefficients 
; that are used in the convolution of the 
; Butterworth filter. Returns the filter.
proc Sound.CalcButterworthCoeffs,\
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
    push    ecx
    push    eax

    push    COUNTSHIFT*4
;    add     eax, SampleArray.x0     ; yikes
    push    eax
    add     eax, 4
    push    eax
    stdcall Memory.memcpy ;, eax+4, eax, COUNTSHIFT*4

    pop     eax
    pop     ecx

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

proc Sound.LFOGetValue,\
    pLFO, triggerTime

    mov     edx, [pLFO]
    push    edx
    fld1                        ; 1
    fdiv    dword[edx+LFO.rhythm]   ; LFOCycleTime
    fld     [currTime]          ; currTime, LFOCycleTime
    fsub    [triggerTime]       ; dt, LFOCycleTime
    movzx   ecx, byte[edx+LFO.mode]
    jecxz   .loopMode   
    fdiv    st0, st1            ; dt/LFOCycleTime = stage
    push    eax                 ; stage
    fst     dword[esp]          ; stage
    fld1                        ; 1, stage
    FPU_CMP                     ; 
    jbe      .interpValue

    pop     eax
    xor     eax, eax

    jmp     .calcValue
.loopMode:


    fprem                       ; stage, LFOCycleTime
    fxch                        ; LFOCycleTime, stage
    fdivp                       ; phase
    ; get interpolation value 
    ;stdcall Sound.interpolatePhase, [edx+LFO.interpType], st0
    push    eax
    fstp    dword[esp]          ; 
.interpValue:
    movzx   eax, byte[edx+LFO.interpType]
    push    eax
  

    
    
    stdcall Sound.interpolatePhase
    
.calcValue:
    pop     edx

    push    eax   ; the result of interp
    fld     dword[edx+LFO.deltaValue]       ; dValue
    fmul    dword[esp]                      ; incrementValue
    fadd    dword[edx+LFO.startValue]       ; resultValue
    fstp    dword[esp]                      ; 
    pop     eax

    ret
endp