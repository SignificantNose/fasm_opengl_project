; routine for acquiring the current value of 
; low frequency oscillator located at pLFO
proc LFO.GetValue uses esi,\
    pLFO, triggerTime

    mov     esi, [pLFO]
    fld1                        ; 1
    fdiv    dword[esi+LFO.rhythm]   ; LFOCycleTime
    fld     [currTime]          ; currTime, LFOCycleTime
    fsub    [triggerTime]       ; dt, LFOCycleTime
    movzx   ecx, byte[esi+LFO.mode]
    jecxz   .loopMode   

;problem here?

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
    movzx   eax, byte[esi+LFO.interpType]
    push    eax    
    stdcall Sound.interpolatePhase
    
.calcValue:

    push    eax   ; the result of interp
    fld     dword[esi+LFO.deltaValue]       ; dValue
    fmul    dword[esp]                      ; incrementValue
    fadd    dword[esi+LFO.startValue]       ; resultValue
    fstp    dword[esp]                      ; 
    pop     eax

    ret
endp