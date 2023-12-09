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
    and     ecx, 00000001b
    jz      .loopMode

;problem here?

    fdiv    st0, st1            ; dt/LFOCycleTime = stage, LFOCycleTime
    fstp    st1                 ; stage
    push    eax                 ; stage
    fst     dword[esp]          ; stage
    fld1                        ; 1, stage
    FPU_CMP                     ; 
    jae      .interpValue

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

    movzx   ecx, byte[esi+LFO.mode]
    and     ecx, 00000010b
    jz      .calcValue
    fld1                           ; 1
    fld1                           ; 1, 1 
    fadd    st0, st1               ; 2, 1
    push    eax
    fmul    dword[esp]             ; 2*x, 1
    fsubp                          ; 1-2*x
    fchs                           ; 2*x-1
    fstp    dword[esp]
    pop     eax 



    
.calcValue:

    push    eax   ; the result of interp
    fld     dword[esi+LFO.deltaValue]       ; dValue
    fmul    dword[esp]                      ; incrementValue
    fadd    dword[esi+LFO.startValue]       ; resultValue
    fstp    dword[esp]                      ; 
    pop     eax

    ret
endp

; routine for modulating the coefficients of the 
; filter based on the filter cutoff frequency at (?)
; the current time  (just for structurizing the code)
proc LFO.ModulateCutoffFreq,\
    pLFO, pFilter

    ; the envelope modulation is not applicable for the 
    ; instrument, as the trigger time must be captured, 
    ; and the trigger time is linked to the message.
    ; so in this case the LFO must be linked to the message,
    ; not the instrument, which is pretty expensive
    stdcall LFO.GetValue, [pLFO], 0.0
    stdcall Sound.CalcButterworthCoeffs, eax, [pFilter]

    ret
endp

; routine for modulating the current pitch of the 
; note. the routine returns the multiplier for the
; base frequency of the note
proc LFO.ModulatePitch uses esi edi,\
    pLFO, pInstrumentMsg

    mov     esi, [pLFO]
    mov     edi, [pInstrumentMsg]

    stdcall LFO.GetValue, esi, [edi + InstrumentMessage.msgData + MessageData.msgTrigger]
    push    eax 
    fld     dword[esp]                                  ; LFOValueUnproc
    fsub    [esi + LFO.startValue]                      ; LFOValueUnproc - startValue = F
    fdiv    [esi + LFO.deltaValue]                      ; F !!!
    fmul    [oneSec]                                    ; F*dt = integral element
    fadd    [edi + InstrumentMessage.LFOPrevValue]      ; F*dt + prevValue
    fst     [edi + InstrumentMessage.LFOPrevValue]      

    fmul    [esi + LFO.deltaValue]                      ; (F+prev)*A
    fldpi
    fldpi
    faddp                                               ; 2*pi, (F+prev)*A   
    fmul    [currTime]                                  ; 2*pi*t, (F+prev)*A
    fdivp                                               ; 2*pi*t/(F+prev)*A
    fld1                                                ; 1, 2*pi*t/(F+prev)*A            
    faddp                                               ; 1+2*pi*t/(F+prev)*A
    fstp    dword[esp]
    pop     eax

    ret 
endp