;    mov     eax, 1.0                ; 5
;    mov     [myowntest], eax        ; 5
;    fld     [myowntest]             ; 6
;    fmul    [myowntest]             ; 6
;    fstp    [myowntest]             ; 6
;    mov     eax, [myowntest]        ; 5
;
;    push    eax                     ; 1
;    fld     dword[esp-4]            ; 4
;    fmul    [myowntest]             ; 6
;    fstp    dword[esp-4]            ; 4
;    pop     eax                     ; 1

;    fistp   word[esp]               ; 3
;    fstp    dword[esp]              ; 3 

DSSCL_NORMAL = 1
DSSCL_PRIORITY = 2
DSSCL_EXCLUSIVE = 3
DSSCL_WRITEPRIMARY = 4
DSBCAPS_GLOBALFOCUS = $8000
DSBCAPS_CTRLPOSITIONNOTIFY = $100  


hDskWnd         dd      ?

STATE_OFF = 0
STATE_ON = 1
LIST_NONE       equ     0
msgListHead     dd      LIST_NONE


; Message poll
messages:

msg1            UnprocessedMessage      <165.0, 6.0, 0.0>, INSTR_SINE
msg2            UnprocessedMessage      <450.0,3.0,0.0>, INSTR_SINE
msg3            UnprocessedMessage      <165.0,3.0,0.0>, INSTR_SAW

;msg1            Message <440.0, INSTR_SINE>, 3.0, 0.0

;msg2            Message <440.0, INSTR_TRIANGLE>, 2.0, 0.0
;msg1            Message <100.0, INSTR_HIHAT>, 0.1, 0.0
;msg2            Message <100.0, INSTR_HIHAT>, 0.05, 0.16
;msg3            Message <100.0, INSTR_HIHAT>, 0.05, 0.32
;msg4            Message <100.0, INSTR_HIHAT>, 0.05, 0.5
;msg5            Message <100.0, INSTR_HIHAT>, 0.05, 0.66
;msg6            Message <100.0, INSTR_HIHAT>, 0.05, 0.82
;msg7            Message <100.0, INSTR_HIHAT>, 0.05, 1.0
;msg8            Message <100.0, INSTR_HIHAT>, 0.05, 1.16
;msg9            Message <100.0, INSTR_HIHAT>, 0.05, 1.32
;msg10           Message <100.0, INSTR_HIHAT>, 0.05, 1.48
;msg11           Message <100.0, INSTR_HIHAT>, 0.05, 1.66
;msg12           Message <100.0, INSTR_HIHAT>, 0.05, 1.82
;msg13           Message <100.0, INSTR_HIHAT>, 0.05, 2.0
;msg14           Message <100.0, INSTR_HIHAT>, 0.05, 2.16
;msg15           Message <100.0, INSTR_HIHAT>, 0.05, 2.32
;msg16           Message <100.0, INSTR_HIHAT>, 0.05, 2.50
;msg17           Message <100.0, INSTR_HIHAT>, 0.05, 2.66
;msg18           Message <100.0, INSTR_HIHAT>, 0.05, 2.82
;msg19           Message <100.0, INSTR_HIHAT>, 0.05, 3.0
;msg20           Message <100.0, INSTR_HIHAT>, 0.05, 3.16
;msg21           Message <100.0, INSTR_HIHAT>, 0.05, 3.32
;msg22           Message <100.0, INSTR_HIHAT>, 0.05, 3.50
;msg23           Message <100.0, INSTR_HIHAT>, 0.05, 3.66
;msg24           Message <100.0, INSTR_HIHAT>, 0.05, 3.82
;msg25           Message <100.0, INSTR_HIHAT>, 0.05, 4.0
;msg26           Message <100.0, INSTR_HIHAT>, 0.05, 4.16
;msg27           Message <100.0, INSTR_HIHAT>, 0.05, 4.32
;msg28           Message <100.0, INSTR_HIHAT>, 0.05, 4.48
;msg29           Message <100.0, INSTR_HIHAT>, 0.05, 4.66
;msg30           Message <100.0, INSTR_HIHAT>, 0.05, 4.82
;msg31           Message <100.0, INSTR_HIHAT>, 0.05, 5.0
;msg32           Message <100.0, INSTR_HIHAT>, 0.05, 5.16
;msg33           Message <100.0, INSTR_HIHAT>, 0.05, 5.32
;msg34           Message <100.0, INSTR_HIHAT>, 0.05, 5.48
;msg4            Message <200.0, INSTR_HIHAT>, 1.0, 0.2
msgEnd:

messagesPtr     dd      messages

seqMain         Sequencer       <LIST_NONE,LIST_NONE,0>, <LIST_NONE,LIST_NONE,0>, 60.0, 0.0, 0.0, 16, 4, 4, 0
;testMsg         Message <660.0,INSTR_HIHAT>, 0.1, 0.1

INTERP_LINEAR   = 0
INTERP_SQUARE   = 1
INTERP_BISQUARE = 2
INTERP_SINE     = 3



frDisc          dd      44100
freqDiscValue   equ     44100
BUFFERSIZE_BYTES equ    2*freqDiscValue*16   
blockSize       dd      BUFFERSIZE_BYTES
ptrPart1        dd      ?
bytesPart1      dd      ?
ptrPart2        dd      ?
bytesPart2      dd      ?

timeValue       dd      0
currTime        dd      0.0
oneSec          dd      0.00002267573
ten             dd      10
maxValue        dd      8000  
randNoise       dd      2000
two             dd      2
three           dd      3
four            dd      4
triangleTemp    dd      0.25

DELETE_FLAG     = 0xFFFFFFFF
dsc             IDirectSound8                       ; it is a pointer to an interface?
dsb             IDirectSoundBuffer8   
dsbd            DSBUFFERDESC sizeof.DSBUFFERDESC, DSBCAPS_GLOBALFOCUS or DSBCAPS_CTRLPOSITIONNOTIFY,\
                BUFFERSIZE_BYTES, 0, mywaveformat, <0,0,0,0>      
mywaveformat    WAVEFORMATEX 1, 2, 44100, 4*44100, 4, 16, 0


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


proc Sound.Hz2Angular,\
    freq

    fldpi                       ; pi
    fldpi                       ; pi, pi
    faddp                       ; 2*pi
    fmul    [freq]              ; 2*pi*freq
    fstp    [freq]
    
    mov     eax, [freq]
    ret
endp


proc Sound.GenSample,\
    oscType,freq

    fld1                ; 1
    fld     [currTime]  ; t, 1
    fmul    [freq]      ; t*freq, 1
    fprem               ; phase, 1
    fstp    st1         ; phase

    mov     eax, [oscType]

    JumpIf OSC_SINE, .sine
    JumpIf OSC_SQUARE, .square
    JumpIf OSC_SAW, .saw
    JumpIf OSC_TRIANGLE, .triangle
    JumpIf OSC_NOISE, .noise
    xor eax, eax
    jmp .Return

.sine:  
    push_st0
    stdcall Sound.Hz2Angular
    FPU_LD eax               ; 2*pi*phase
    fsin                     ; sin(2*pi*phase)
    jmp .getResult
.square:

    ; combine with sine??
    push_st0
    stdcall Sound.Hz2Angular
    FPU_LD eax
    fsin                     ; sin(2*pi*phase)
    fldz                     ; 0, sin    
    FPU_CMP                  ; 
    fld1                     ; 1
    ja   @F
    fchs
@@:
    jmp .getResult
.saw:
    fimul   [two]            ; 2*t
    fld1                     ; 1, 2*t
    fsubp                    ; 2*t-1
    jmp .getResult
.triangle:
    
    fimul       [four]          ; 4*t
    fchs                        ; -4*t
    fld1                        ; 1, -4*t
    faddp                       ; 1-4*t
    fabs                        ; |1-4*t|
    fchs                        ; -|1-4*t|
    fiadd       [two]           ; 2-|1-4*t|
    fabs                        ; |2-|1-4*t||
    fld1                        ; 1, |2-|1-4*t||
    fsubp                       ; |2-|1-4*t||-1

;;;    fimul    [four]          ; 4*t
;;;    fld      st0             ; 4*t, 4*t
;;;    fld1                     ; 1, 4*t, 4*t
;;;    FPUCMP                   ; 4*t
;;;    ja      .getResult
;;;    fld      st0             ; 4*t, 4*t
;;;    fild      [three]        ; 3, 4*t, 4*t
;;;    FPUCMP                   ; 4*t
;;;    jb      .finalCase
;;;    fchs                     ; -4*t
;;;    fiadd   [two]            ; 2-4*t
;;;    jmp     .getResult
;;;.finalCase:
;;;    fisub    [four]          ; 4*t-4

;    fstp    [phaseBuffer]
;    stdcall Sound.Hz2Angular, [phaseBuffer]
;    mov     [phaseBuffer], eax
;    fld     [phaseBuffer]    ; 2*pi*phase
;    fsin                     ; sin(2*pi*phase)
;    fld     st0              ; sin, sin
;    fmul    st0, st0         ; sin^2, sin
;    fld1                     ; 1, sin^2, sin
;    fsubrp                   ; 1-sin^2, sin
;    fsqrt                    ; sqrt(1-sin^2), sin
;    fpatan                   ; arctg == arcsin
;    fld1                     ; 1, arcsin
;    fld1                     ; 1, 1, arcsin
;    faddp                    ; 2, arcsin
;    fmulp                    ; 2*arcsin
;    fldpi                    ; pi, 2*arcsin
;    fdivp                    ; 2*arcsin/pi
    jmp .getResult
.noise:

    ;stdcall     Rand.GetRandomNumber, 0, [randNoise]
    fstp        st0                   ; 
    stdcall     Rand.GetRandomInBetween, 0, [randNoise]
    push        eax
    fild        dword[esp]            ; x = [0,max]
    pop         eax
    fild        [randNoise]           ; max, x
    fidiv       [two]                 ; max/2, x
    fsubp                             ; x = [-max/2,max/2]
    fidiv       [randNoise]           ; x = [-1/2, 1/2]
    fimul       [two]                 ; x = [-1,1]
    

.getResult:

    push_st0
    pop     eax

.Return:
    ret
endp

;proc Sound.GenSample,\
;    soundMsg, time
;
;    mov     eax, [soundMsg]
;    fld1                     ; 1 
;    fld     [time]           ; t, 1
;    fmul    [eax+Message.msgNote+Note.freq]           ; t*freq, 1
;    fprem                    ; phase, 1
;    fstp    st1              ; phase
;
;    movzx   eax, word[eax+Message.msgNote+Note.instrumentOffset]
;    imul    eax, sizeof.Instrument
;    add     eax, instruments
;    movzx   eax, word[eax+Instrument.oscType]
;
;    JumpIf OSC_SINE, .sine
;    JumpIf OSC_SQUARE, .square
;    JumpIf OSC_SAW, .saw
;    JumpIf OSC_TRIANGLE, .triangle
;    JumpIf OSC_NOISE, .noise
;    xor eax, eax
;    jmp .Return
;
;.sine:  
;    push_st0
;    stdcall Sound.Hz2Angular
;    FPU_LD eax               ; 2*pi*phase
;    fsin                     ; sin(2*pi*phase)
;    jmp .getResult
;.square:
;
;    ; combine with sine??
;    push_st0
;    stdcall Sound.Hz2Angular
;    FPU_LD eax
;    fsin                     ; sin(2*pi*phase)
;    fldz                     ; 0, sin    
;    FPU_CMP                   ; 
;    fld1                     ; 1
;    ja   @F
;    fchs
;@@:
;    jmp .getResult
;.saw:
;    fimul   [two]            ; 2*t
;    fld1                     ; 1, 2*t
;    fsubp                    ; 2*t-1
;    jmp .getResult
;.triangle:
;    
;    fimul       [four]          ; 4*t
;    fchs                        ; -4*t
;    fld1                        ; 1, -4*t
;    faddp                       ; 1-4*t
;    fabs                        ; |1-4*t|
;    fchs                        ; -|1-4*t|
;    fiadd       [two]           ; 2-|1-4*t|
;    fabs                        ; |2-|1-4*t||
;    fld1                        ; 1, |2-|1-4*t||
;    fsubp                       ; |2-|1-4*t||-1
;
;;;;    fimul    [four]          ; 4*t
;;;;    fld      st0             ; 4*t, 4*t
;;;;    fld1                     ; 1, 4*t, 4*t
;;;;    FPUCMP                   ; 4*t
;;;;    ja      .getResult
;;;;    fld      st0             ; 4*t, 4*t
;;;;    fild      [three]        ; 3, 4*t, 4*t
;;;;    FPUCMP                   ; 4*t
;;;;    jb      .finalCase
;;;;    fchs                     ; -4*t
;;;;    fiadd   [two]            ; 2-4*t
;;;;    jmp     .getResult
;;;;.finalCase:
;;;;    fisub    [four]          ; 4*t-4
;
;;    fstp    [phaseBuffer]
;;    stdcall Sound.Hz2Angular, [phaseBuffer]
;;    mov     [phaseBuffer], eax
;;    fld     [phaseBuffer]    ; 2*pi*phase
;;    fsin                     ; sin(2*pi*phase)
;;    fld     st0              ; sin, sin
;;    fmul    st0, st0         ; sin^2, sin
;;    fld1                     ; 1, sin^2, sin
;;    fsubrp                   ; 1-sin^2, sin
;;    fsqrt                    ; sqrt(1-sin^2), sin
;;    fpatan                   ; arctg == arcsin
;;    fld1                     ; 1, arcsin
;;    fld1                     ; 1, 1, arcsin
;;    faddp                    ; 2, arcsin
;;    fmulp                    ; 2*arcsin
;;    fldpi                    ; pi, 2*arcsin
;;    fdivp                    ; 2*arcsin/pi
;    jmp .getResult
;.noise:
;
;    ;stdcall     Rand.GetRandomNumber, 0, [randNoise]
;    fstp        st0                   ; 
;    stdcall     Rand.GetRandomInBetween, 0, [randNoise]
;    push        eax
;    fild        dword[esp]            ; x = [0,max]
;    pop         eax
;    fild        [randNoise]           ; max, x
;    fidiv       [two]                 ; max/2, x
;    fsubp                             ; x = [-max/2,max/2]
;    fidiv       [randNoise]           ; x = [-1/2, 1/2]
;    fimul       [two]                 ; x = [-1,1]
;    
;
;
;
;.getResult:
;
;    push_st0
;    pop     eax
;
;.Return:
;    ret
;endp

;proc Sound.CreateOsc, type, freqHz
;    invoke      HeapAlloc, [hHeap], 8, sizeof.Oscillator
;    push        eax
;
;    stdcall     Sound.Hz2Angular, [freqHz]
;    mov         ecx, eax
;
;    pop         eax
;    mov         [eax+Oscillator.freq], ecx    
;
;    mov         cx, word[type]
;    mov         [eax+Oscillator.oscType], cx
;    ret
;endp

proc Sound.NewMessage,\
    unprocMsg

;    invoke HeapAlloc, [hHeap], 8, sizeof.DoublyLinkedList
;    mov ecx, [soundMsg]
;    mov [eax+DoublyLinkedList.data], ecx
;
;    mov ecx, [msgListHead]    
;    mov [eax+DoublyLinkedList.next], ecx
;
;
;    mov [eax+DoublyLinkedList.prev], LIST_NONE
;    ;cmp ecx, LIST_NONE
;    ;je  .return
;    jecxz .return            
;    mov [ecx+DoublyLinkedList.prev], eax
;.return:
;    mov [msgListHead], eax




    mov     eax, [unprocMsg]
    movzx   eax, byte[eax+UnprocessedMessage.instrNumber]
    imul    eax, sizeof.Instrument
    add     eax, instruments
    push    eax
    push    eax
    invoke HeapAlloc, [hHeap], 8, sizeof.DoublyLinkedList
    pop     ecx
    ; ecx = instrument
    ; eax = msg node

    mov     edx, [unprocMsg]
    add     edx, UnprocessedMessage.msgData
    mov     [eax+DoublyLinkedList.data], edx

    mov     ecx, [ecx+Instrument.msgPollPtr]
    mov     [eax+DoublyLinkedList.next], ecx

    ; CAN BE REMOVED: THE ALLOCATED MEMORY IS INITIALIZED WITH ZERO
    mov     [eax+DoublyLinkedList.prev], LIST_NONE
    jecxz   .return
    mov     [ecx+DoublyLinkedList.prev], eax

.return:
    pop     ecx
    mov     [ecx+Instrument.msgPollPtr], eax

    
    


    ret
endp

proc Sound.RemoveInstrMessage,\
    instr,soundMsg

    mov ecx, [instr]
    mov eax, [soundMsg]
    cmp eax, [ecx+Instrument.msgPollPtr]
    je .isHead
    mov edx, [eax+DoublyLinkedList.prev]
    mov ecx, [eax+DoublyLinkedList.next]
    mov [edx+DoublyLinkedList.next], ecx
    push ecx
    ;cmp ecx, LIST_NONE
    ;je .return
    jcxz .return 
    mov  [ecx+DoublyLinkedList.prev], edx
    jmp .return

.isHead:
    mov edx, [eax+DoublyLinkedList.next]
    mov [ecx+Instrument.msgPollPtr], edx
    push edx
.return:
    invoke HeapFree, [hHeap], 0, eax
    pop eax
    ret
endp

;    mov eax, [soundMsg]
;    cmp eax, [msgListHead]
;    je .isHead
;
;    mov edx, [eax+DoublyLinkedList.prev]
;    mov ecx, [eax+DoublyLinkedList.next]
;    mov [edx+DoublyLinkedList.next], ecx
;    push ecx
;    ;cmp ecx, LIST_NONE
;    ;je .return
;    jecxz .return
;    mov [ecx+DoublyLinkedList.prev], edx
;    jmp .return
;.isHead:
;    mov edx, [eax+DoublyLinkedList.next]
;    mov [msgListHead], edx
;    push edx
;
;.return:
;    invoke HeapFree, [hHeap], 0, eax
;    pop eax
;    ret
;
;    ret
;endp

; will be deprecated
proc Sound.RemoveMessage,\
    soundMsgNode
    
    mov eax, [soundMsgNode]
    cmp eax, [msgListHead]
    je .isHead

    mov edx, [eax+DoublyLinkedList.prev]
    mov ecx, [eax+DoublyLinkedList.next]
    mov [edx+DoublyLinkedList.next], ecx
    push ecx
    ;cmp ecx, LIST_NONE
    ;je .return
    jecxz .return
    mov [ecx+DoublyLinkedList.prev], edx
    jmp .return
.isHead:
    mov edx, [eax+DoublyLinkedList.next]
    mov [msgListHead], edx
    push edx

.return:
    invoke HeapFree, [hHeap], 0, eax
    pop eax
    ret
endp

proc Sound.interpolatePhase,\
    interpType, phase

    mov     eax, [interpType]

    
    fld     [phase]             ; phase
    JumpIf  INTERP_LINEAR, .linear
    JumpIf  INTERP_SQUARE, .square
    JumpIf  INTERP_BISQUARE, .bisquare
    JumpIf  INTERP_SINE, .sine

    xor eax, eax
    fstp    st0
    jmp .return
;.linear:
;    ; yikes
;    jmp     .store
.square:
    fmul    [phase]             ; phase^2
    jmp     .store
.bisquare:
    fmul    [phase]             ; phase^2
    fld     st0                 ; phase^2, phase^2
    fmulp                       ; phase^4

    jmp     .store
.sine:
    fldpi                       ; pi, phase
    fidiv   [two]               ; pi/2, phase
    fmulp                       ; phase*pi/2
    fsin                        ; sin(phase*pi/2)

.linear:
.store:
    ;fstp    [phase]
    ;mov     eax, [phase]        ; 11 B

    push    eax                  ; 1 B
    FPU_STP eax                  ; 4 B

    

.return:
    ret
endp

proc Sound.ADSAmp,\
    env, soundMsg, dt

    mov     eax, [env]
    fld     [dt]            ; dt

.attack:
    fld     st0                                             ; dt, dt
    fsub    [eax+EnvelopeADSR.attackTime]    ; dt-tA, dt
    fldz                                                    ; 0, dt-tA, dt
    FPU_CMP                                                  ; dt
    jb          .decay
    
    fdiv    [eax+EnvelopeADSR.attackTime]    ; phase


    push    eax
    FPU_STP ecx
    movzx   eax, word[eax+EnvelopeADSR.interpRelease]
    stdcall Sound.interpolatePhase, eax, ecx
    jmp .return

.decay:
    fsub        [eax+EnvelopeADSR.attackTime]    ; dt-tA
    fld         st0                                             ; dt-tA, dt-tA
    fsub        [eax+EnvelopeADSR.decayTime]     ; dt-tA-tD, dt-tA
    fldz                                                        ; 0, dt-tA-tD, dt-tA
    FPU_CMP                                                      ; dt-tA
    jb          .sustain
    fdiv        [eax+EnvelopeADSR.decayTime]     ; phase
    fchs                                                        ; -phase
    fld1                                                        ; 1, -phase
    faddp                                                       ; 1-phase


    push        eax
    FPU_STP     ecx

    push        eax
    movzx       eax, word[eax+EnvelopeADSR.interpDecay]
    stdcall     Sound.interpolatePhase, eax, ecx
    pop         ecx
    FPU_LD      eax                                     ; [0;1] == sustain phase
    fld         [ecx+EnvelopeADSR.startAmpl]                         ; 1, [0;1]
    fsub        [ecx+EnvelopeADSR.sustainAmpl]                       ; dAmpl, [0;1]
    fmulp                                               ; ampOffset == amplitude phase of decay
    fadd        [ecx+EnvelopeADSR.sustainAmpl]                       ; res
    push        ecx
    FPU_STP     eax
    jmp         .return   

.sustain:
    fstp        st0                              ; 
    fld         [eax+EnvelopeADSR.sustainAmpl]   ; resultAmp
    push        eax
    FPU_STP     eax

.return:
    ret
endp


; returns the RELATIVE value of the amplitude
proc Sound.GetADSRAmp,\
    env, soundMsg

    mov         eax, [soundMsg]
    fld         [currTime]                      ; t
    fsub        [eax+Message.msgTrigger]    ; dt
    fld         st0                         ; dt, dt
    fsub        [eax+Message.msgDuration]   ; dt-tDur, dt
    fld         st0                         ; dt-tDur, dt-tDur, dt
    fldz                                    ; 0, dt-tDur, dt-tDur, dt
    mov         eax, [env]
    FPU_CMP                                 ; dt-tDur, dt
    ja          .ADSphase

    fdiv        [eax+EnvelopeADSR.releaseTime]   ; (dt-tDur)/tR, dt
    fld         st0                 ; (dt-tDur)/tR, (dt-tDur)/tR, dt
    fld1                            ; 1, (dt-tDur)/tR, (dt-tDur)/tR, dt
    FPU_CMP                         ; (dt-tDur)/tR, dt
    push        eax
    fchs                            ; -(dt-tDur)/tR, dt
    fld1                            ; 1, -(dt-tDur)/tR, dt
    faddp                           ; 1-(dt-tDur)/tR, dt
    FPU_STP     edx                 ; dt
    fstp        st0                 ;
    jb          .delete
    movzx       eax, word[eax+EnvelopeADSR.interpRelease]


    stdcall     Sound.interpolatePhase, eax, edx
    push        eax

    mov         eax, [soundMsg]
    stdcall     Sound.ADSAmp, [env], [soundMsg], [eax+Message.msgDuration]
    FPU_LD      eax                 ; lastADSvalue
    pop         eax
    fmul        dword[esp]          ; resValue
    FPU_STP     eax
    jmp .return

.delete:
    mov         eax, DELETE_FLAG
    jmp         .return

.ADSphase:
    fstp        st0                         ; dt
    push        eax
    FPU_STP     edx                         ; edx has dt
    
    stdcall     Sound.ADSAmp, [env], [soundMsg], edx     

.return:
    ret
endp

proc Sound.AddOscillator,\
    osc, instr
    
    invoke  HeapAlloc, [hHeap], 8, sizeof.DoublyLinkedList
    mov     ecx, [osc]
    mov     [eax+DoublyLinkedList.data], ecx
    mov     ecx, [instr]
    push    ecx
    mov     ecx, [ecx+Instrument.oscListPtr]
    mov     [eax+DoublyLinkedList.next], ecx

    ; CAN BE REMOVED: THE ALLOCATED MEMORY IS INITIALIZED WITH ZERO
    mov     [eax+DoublyLinkedList.prev], LIST_NONE
    jecxz   .return
    mov     [ecx+DoublyLinkedList.prev], eax

.return:
    pop     ecx
    mov     [ecx+Instrument.oscListPtr], eax

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

    nop
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
    fld     dword[esp]      ; detune 
    fchs                    ; -detune
    fstp    dword[esp]    
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
    fstp    [leftMul]       ;
    fld1                    ; 1
    fstp    [rightMul]      ;
    jmp     .saveSample

@@:
    ; negative
    ; left = 1, right = 1 + panPhase
    faddp                   ; 1+panPhase
    fstp    [rightMul]      ;
    fld1                    ; 1
    fstp    [leftMul]

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
    fadd    [step]          ; newStep
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



    

    
    ; I need to go through [-detune; detune]
    ; need to get a step for each iteration 
    ; and modify pitch and the pan for each iteration



    ;stdcall Sound.PowXY, 10.0, 2.5
    jmp .return
.noUnison:
    stdcall Sound.GenSample, eax, [freq]
    ; returns float
    mov     edx, eax

.return:

    ret
endp


; returns an accurate two-channel sample: 
; integer 2-byte stereo
proc Sound.GetInstrumentSample,\
    instr
    locals
        smplLeft        dd      ?
        smplRight       dd      ?
        resLeft         dd      0.0
        resRight        dd      0.0
    endl

    mov     edx, [instr]

    ; get current message from message list
    ; and generate everything for it

    mov     ecx, [edx+Instrument.msgPollPtr]
.loopMsgs:
    jecxz   .return
    push    edx
    push    ecx
    ; ecx has the address of the message


    push    edx

    fldz                ; 0
    fst     [smplLeft]  ; 0
    fstp    [smplRight] ;

    mov     eax, [edx+Instrument.oscListPtr]
.loopOscs:    
    cmp     eax, LIST_NONE
    je      .ADSRStage

    push    eax
    push    ecx
    ; probably will use 2 registers to return: eax and edx
    mov     ecx, [ecx+DoublyLinkedList.data]
    stdcall     Sound.GetOscSamples, [eax+DoublyLinkedList.data], [ecx+Message.msgFreq]

    FPU_LD  eax         ; sampleRight
    fadd    [smplRight] ; newSampleRight
    fstp    [smplRight]
    pop     eax
    FPU_LD  edx         ; sampleLeft
    fadd    [smplLeft]  ; newSampleLeft
    fstp    [smplLeft] 
    pop     edx


    pop     ecx
    pop     eax
    mov     eax, [eax+DoublyLinkedList.next]
    jmp .loopOscs

.ADSRStage:
    
    pop     edx
    pop     ecx
    push    ecx
    stdcall Sound.GetADSRAmp, [edx+Instrument.envelope], [ecx+DoublyLinkedList.data]
    cmp     eax, DELETE_FLAG
    je      .delete

    push    eax
    fld     [smplLeft]  ; left
    fmul    dword[esp]  ; resLeft
    fadd    [resLeft]   ; newLeft
    fstp    [resLeft]

    fld     [smplRight] ; right
    fmul    dword[esp]  ; resRight
    fadd    [resRight]  ; newRight
    fstp    [resRight]
    pop     eax



    pop     ecx
    mov     ecx, [ecx+DoublyLinkedList.next]

    pop     edx
    jmp     .loopMsgs

.delete:
    pop     ecx
    stdcall Sound.RemoveInstrMessage, [instr], ecx
    ;mov     ecx, eax
    xchg    ecx, eax

    pop     edx
    jmp     .loopMsgs
.return:
    push    eax
    fld     [resLeft]       ; resLeft
    fimul   [maxValue]      ; intResLeft
    ; will have to think about it
    fistp   dword[esp]
    pop     eax 

    shl     eax, 16

    push    eax
    fld     [resRight]      ; resRight
    fimul   [maxValue]      ; intResRight
    fistp   dword[esp]
    pop     edx
    and     edx, 0xFFFF
    or      eax, edx



    ret
endp

proc Sound.PlayMsgList

;    mov ecx, [msgListHead]
;    xor eax, eax
;
;.looper:
;    ;cmp ecx, LIST_NONE
;    ;je .return
;    jecxz .return
;    push eax
;    push ecx
;
;
;    mov ecx, [ecx+DoublyLinkedList.data]
;    ; ecx has the pointer to the message
;    ;stdcall     Sound.GenSample, msg, [time]
;    ;stdcall     Sound.GetADSRAmp, ecx, [time]
;    ;multiply the acquired values and get the needed value
;
;    push ecx
;    stdcall     Sound.GenSample, ecx, [currTime]
;    pop         ecx
;    push        eax
;
;
;    movzx       eax, word[ecx+Message.msgNote+Note.instrumentOffset]
;    imul        eax, sizeof.Instrument
;    add         eax, instruments+Instrument.env
;    stdcall     Sound.GetADSRAmp, eax, ecx, [currTime]
;    cmp         eax, DELETE_FLAG
;    je          .delete
;
;
;
;    fld         dword[esp]              ; sample
;    push        eax
;    fmul        dword[esp]              ; resAmp
;    pop         eax
;    fimul       [maxValue]              ; res
;    ; bad
;    fistp       word[esp]
;    pop         eax
;    and         eax, 0x0000FFFF
;
;
;    pop ecx
;    mov ecx, [ecx+DoublyLinkedList.next]
;
;    pop edx
;    add eax, edx
;
;    jmp         .looper
;.delete:
;;    pop eax
;;    pop eax
;;    stdcall Sound.RemoveMessage, eax
;    pop eax
;    stdcall     Sound.RemoveMessage
;    ; eax has the address of a next node
;    mov ecx, eax
;
;    pop eax
;    jmp .looper
;.return:
;    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov ecx, instruments
    xor eax, eax
.looper:
    cmp ecx, instrumentsEnd
    je .return
    push ecx
    push eax

    ; instruments must return a ready sample - that is, stereo accurate and int
    stdcall Sound.GetInstrumentSample, ecx

    pop edx
    add ax, dx
    rol eax, 16
    rol edx, 16
    add ax, dx
    rol eax, 16
    pop ecx
    add ecx, sizeof.Instrument
    jmp .looper
.return:
    ret


endp


proc Sound.MessagePollAdd

    mov         ecx, [messagesPtr]
.addMsgs:
    cmp         ecx, msgEnd
    je          .msgsAdded


    fld         [currTime]                                               ; t
    fld         [ecx+UnprocessedMessage.msgData+Message.msgTrigger]         ; triggerTime, t
    FPU_CMP
    jae         .msgsAdded
    push        ecx
    stdcall     Sound.NewMessage, ecx
    pop         ecx
    add         ecx, sizeof.UnprocessedMessage
    mov         [messagesPtr], ecx

    jmp         .addMsgs
.msgsAdded:

    ret
endp



; routine for defining starting time of sequencer
; (relatively to the current time):
; calculates the elapsed time, so that the 
; sequencer starts playing [startTime] seconds
; after the current time
proc Sound.StartTimeSequencer,\
    startTime

    mov     eax, seqMain
    fld     [startTime]                     ; startTime
    fstp    [eax+Sequencer.timeElapsed]     ; 
    mov     word[eax+Sequencer.currentBeat], -1

    ret
endp


; routine for adding another instrument to the sequencer.
; Takes the message values for the sequencer and the 
; pattern of the message. Adds the sequencer instrument
; to the main sequencer
proc Sound.AddSequencer,\
    soundMsg, pattern

    
; creating new message node
    invoke  HeapAlloc, [hHeap], 8, sizeof.DoublyLinkedList
    mov     ecx, [soundMsg]
    mov     [eax+DoublyLinkedList.data], ecx

    mov     ecx, [seqMain+Sequencer.msgListHead]
    mov     [eax+DoublyLinkedList.next], ecx
    ;cmp     ecx, LIST_NONE
    ;je      .finishMessage
    jcxz    .finishMessage
    mov     [ecx+DoublyLinkedList.prev], eax
.finishMessage:
    mov     [seqMain+Sequencer.msgListHead], eax

; creating new pattern node
    invoke  HeapAlloc, [hHeap], 8, sizeof.DoublyLinkedList
    mov     ecx, [pattern]
    mov     [eax+DoublyLinkedList.data], ecx

    mov     ecx, [seqMain+Sequencer.patternListHead]
    mov     [eax+DoublyLinkedList.next], ecx

    ;cmp     ecx, LIST_NONE
    ;je      .finishPattern
    jcxz    .finishPattern
    mov     [ecx+DoublyLinkedList.prev], eax
.finishPattern:
    mov     [seqMain+Sequencer.patternListHead], eax

    ret
endp


proc Sound.CreateMsgCopy uses edi esi,\
    soundMsg

    invoke  HeapAlloc, [hHeap], 8, sizeof.Message
    ;push    eax
    mov     edi, eax
    mov     esi, [soundMsg]
    mov     ecx, sizeof.Message
;.looper:
    ;movsb   
    ;loop .looper
    rep movsb   
    ;pop     eax

    ret
endp



; probably will not work: new message logic
proc Sound.UpdateSequencer

    ; RESOLVE ONE SEC

    mov     ecx, seqMain
    fld     [ecx+Sequencer.timeElapsed]     ; tElapsed
    fsub    [oneSec]                        ; newTime

    fld     st0                             ; newTime, newTime
    ;fld     [ecx+Sequencer.timeOneBeat]     ; dt, newTime, newTime
    fldz                                    ; 0, newTime, newTime
    FPU_CMP                                 ; newTime
    ;jmp     .return
    jbe      .return
; adding another sequence of notes instead


    ;fsub    [ecx+Sequencer.timeOneBeat]     ; finishTime
    fadd    [ecx+Sequencer.timeOneBeat]      ; finishTime

    mov     ax, word[ecx+Sequencer.currentBeat]
    inc     ax
    xor     edx, edx
    div     word[ecx+Sequencer.totalBeats] 
    ; now (e)dx has the current beat
    mov     word[ecx+Sequencer.currentBeat], dx




;goal: to copy a message in case it corresponds to the pattern and poll it

    push    ecx

    mov     eax, [ecx+Sequencer.patternListHead]
    mov     ecx, [ecx+Sequencer.msgListHead]

.looper:
    ;cmp     ecx, LIST_NONE
    ;je      .msgsEnded
    jcxz    .msgsEnded
    push    ecx
    push    eax
    push    edx

    mov     eax, [eax+DoublyLinkedList.data]
    bt      eax, edx
    jnc     .notNewMessage
    ;mov     eax, [eax+DoublyLinkedList.data]
    ;stdcall Sound.CreateMsgCopy, eax
    stdcall  Sound.CreateMsgCopy, [ecx+DoublyLinkedList.data]

    mov      ecx, [currTime]
    mov      [eax+Message.msgTrigger], ecx
    stdcall  Sound.NewMessage, eax





.notNewMessage:


    pop     edx
    pop     eax
    pop     ecx
    mov     eax, [eax+DoublyLinkedList.next]
    mov     ecx, [ecx+DoublyLinkedList.next]
    jmp     .looper

.msgsEnded:
    pop     ecx
    
.return:
    fstp    [ecx+Sequencer.timeElapsed]     ;

    ret
endp


proc Sound.init uses edi ecx
    invoke      GetDesktopWindow
    mov         [hDskWnd], eax          ; do I need it though?
    invoke      DirectSoundCreate8, NULL, dsc, NULL

    cominvk     dsc, SetCooperativeLevel, [hDskWnd], DSSCL_PRIORITY
    cominvk     dsc, CreateSoundBuffer, dsbd, dsb, NULL
    cominvk     dsb, Lock, 0, [blockSize], ptrPart1, bytesPart1, ptrPart2, bytesPart2, 0

    
; initialization of oscillators
    ;stdcall     Sound.AddOscillator, oscSine, instrSine
    stdcall     Sound.AddOscillator, oscSaw, instrSaw
; initialization of sequencer
;    mov         ecx, seqMain
;    mov         edx, 60.0
;    FPU_LD      edx                             ; 60.0
;    fdiv        [ecx+Sequencer.tempo]           ; dtOneBeat
;    movzx       eax, [ecx+Sequencer.beats]
;    push        eax
;    fidiv       dword[esp]                      ; dt
;    pop         eax
;    fstp        [ecx+Sequencer.timeOneBeat]     ; 
;    pop         edx
;    mov         dl, byte[ecx+Sequencer.beats]
;    mov         al, byte[ecx+Sequencer.subBeats]
;    imul        dl
;    mov         word[ecx+Sequencer.totalBeats], ax
;    stdcall     Sound.AddSequencer, testMsg, 7555h
;    stdcall     Sound.StartTimeSequencer, 0.0

; initialization of a global variable for one second
    mov         eax, 44100
    push        eax
    fld1                    ; 1
    fidiv       dword[esp]  ; dt
    fstp        [oneSec]    ;
    pop         eax



    mov         edi, [ptrPart1]
    mov         ecx, BUFFERSIZE_BYTES/4
.looper:
    push        ecx


    fild        [timeValue]     ; timeCount 
    fidiv       [frDisc]        ; time

    ; I made the currTime a global variable purely because of saving some bytes
    fstp        [currTime]
    ; so that the three next routines shouldn't allocate memory for routine parameter
    ; maybe there will be no choice but making them routine parameters


    
    stdcall     Sound.MessagePollAdd

;    stdcall     Sound.UpdateSequencer
    
    stdcall     Sound.PlayMsgList
    stosw
    ror         eax, 16
    stosw   

    inc         [timeValue]
    pop         ecx
    loop .looper


    cominvk dsb, Unlock, [ptrPart1], [bytesPart1], [ptrPart2], [bytesPart2]
    
    cominvk dsb, Play, 0, 0, 0
    ret
endp