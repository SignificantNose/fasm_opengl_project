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
    osc, freq
    locals 
        step        dd      ?
        two         dd      ?
        twelve      dd      ?
        left        dd      ?
        right       dd      ?
        leftMul     dd      ?
        rightMul    dd      ?
    endl

    ; hate it, but for now let it be this way
    mov     ecx, [osc]
    movzx   eax, byte[ecx+Oscillator.oscType]
    mov     edx, [ecx+Oscillator.detune]

    cmp     edx, 0
    je      .noUnison


    movzx   ecx, byte[ecx+Oscillator.voices]
    mov     [two], 2.0
    mov     [twelve], 12.0
    mov     [left], 0.0
    mov     [right], 0.0

    push    edx
    fld     dword[esp]      ; detune
    fmul    [two]           ; 2*detune
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
    fdiv    [twelve]        ; detune/12
    fstp    dword[esp]
    pop     eax
    stdcall Sound.PowXY, 2.0, eax
    push    eax
    fld     dword[esp]      ; detunator
    fmul    [freq]          ; tune
    fstp    dword[esp]
    pop     eax

    mov     ecx, [osc]
    movzx   ecx, [ecx+Oscillator.oscType]
    stdcall Sound.GenSample, ecx, eax

    fld1                    ; 1
    fld     dword[esp]      ; currDetune, 1
    fdiv    [two]           ; panPhase, 1
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

    mov     ecx, [osc]
    movzx   ecx, byte[ecx+Oscillator.voices]
    push    ecx
    fld     [left]      ; left
    fidiv   dword[esp]  ; finalLeft
    push    eax
    fstp    dword[esp]  
    pop     eax
    fld     [right]     ; right
    fidiv   dword[esp]  ; finalRight
    fstp    dword[esp]
    pop     edx

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
; Butterworth filter
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

    mov     edx, [eax+SampleArray.x1]
    mov     [eax+SampleArray.x2], edx
    mov     edx, [eax+SampleArray.x0]
    mov     [eax+SampleArray.x1], edx
    mov     edx, [rawSample]
    mov     [eax+SampleArray.x0], edx

    mov     edx, [eax+SampleArray.y1]
    mov     [eax+SampleArray.y2], edx
    mov     edx, [eax+SampleArray.y0]
    mov     [eax+SampleArray.y1], edx
    
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