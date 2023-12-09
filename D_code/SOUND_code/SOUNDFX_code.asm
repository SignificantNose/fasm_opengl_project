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


; think of transferring a whole message here
proc Sound.GetOscSamples uses esi edi,\
    pOsc, instrMsg
    locals 
        step        dd      ?
        NumTwo      dd      ?
        NumTwelve   dd      ?
        left        dd      ?
        right       dd      ?
        leftMul     dd      ?
        rightMul    dd      ?
        freq        dd      ?
    endl

    ; hate it, but for now let it be this way
    mov     esi, [pOsc]
    mov     edi, [instrMsg]
    mov     eax, [edi + InstrumentMessage.msgData + MessageData.msgFreq]
    mov     [freq], eax
    ; get cutofffreqlfo and cmp with 0 to make sure that it's present
    ; eax = Sound.LFOGetValue
    ; freq*=eax
    mov     eax, [esi+Oscillator.pitchLFO]
    cmp     eax, 0
    je      .noPitchLFO


    stdcall     LFO.ModulatePitch, eax, edi
    push        eax
    fld         dword[esp]
    fmul        [freq] 
    fstp        [freq] 
    pop         eax


.noPitchLFO:
    ; after cahnging the LFO, unison can be applied

    movzx   eax, byte[esi+Oscillator.oscType]
    mov     edx, [esi+Oscillator.detune]

    cmp     edx, 0
    je      .noUnison


    movzx   ecx, byte[esi+Oscillator.voices]
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
    ;pop     edi
    ; eax keeps track of the current detune

.looper:
    push    ecx
    push    eax

    ;push    edi 
    push    eax
    fld     dword[esp]      ; currDetune
    fdiv    [NumTwelve]     ; detune/12
    fstp    dword[esp]

    ; can be optimized: 
    ; stdcall Sound.PowXY, 2.0
    ; but that's for later. now:
    pop     eax
    stdcall Sound.PowXY, 2.0, eax

    push    eax
    fld     dword[esp]      ; detunator
    fmul    [freq]          ; tune
    fstp    dword[esp]
    pop     eax

    ;mov     ecx, [pOsc]
    movzx   ecx, [esi+Oscillator.oscType]
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

    ;mov     ecx, [pOsc]
    movzx   ecx, byte[esi+Oscillator.voices]
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
