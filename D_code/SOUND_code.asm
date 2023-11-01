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


OSC_SINE = 0
OSC_SQUARE = 1
OSC_SAW = 2
OSC_TRIANGLE = 3
OSC_NOISE = 4
hDskWnd         dd      ?

STATE_OFF = 0
STATE_ON = 1

instruments:
INSTR_SINE = ($-instruments)
instrSine      Instrument      <0.5,0.5,0.5,0.5, 1.0 ,INTERP_LINEAR,INTERP_LINEAR,INTERP_LINEAR>, OSC_SINE

INSTR_NOISE = ($-instruments)
instrNoise     Instrument      <0.5,0.5,0.5,0.5, 1.0 ,INTERP_LINEAR,INTERP_LINEAR,INTERP_LINEAR>, OSC_NOISE

INSTR_SAW = ($-instruments)
instrSaw       Instrument      <0.1,0.1,0.1,0.5, 1.0 ,INTERP_LINEAR,INTERP_LINEAR,INTERP_LINEAR>, OSC_SAW

INSTR_TRIANGLE = ($-instruments)
instrTriangle  Instrument      <0.5,0.5,0.5,0.5, 1.0 ,INTERP_LINEAR,INTERP_LINEAR,INTERP_LINEAR>, OSC_TRIANGLE

INSTR_HIHAT = ($-instruments)
instrHiHat     Instrument      <0.0001,0.181,0.1,0.0, 0.3 ,INTERP_LINEAR,INTERP_LINEAR,INTERP_LINEAR>, OSC_NOISE

LIST_NONE       equ     0
msgListHead     dd      LIST_NONE


; Message poll
messages:
msg1            Message <440.0, INSTR_SINE>, 3.0, 0.0

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
testMsg         Message <660.0,INSTR_HIHAT>, 0.1, 0.1

INTERP_LINEAR   = 0
INTERP_SQUARE   = 1
INTERP_BISQUARE = 2
INTERP_SINE     = 3


BUFFERSIZE_BYTES equ  2*44100*16   
blockSize       dd      BUFFERSIZE_BYTES
ptrPart1        dd      ?
bytesPart1      dd      ?
ptrPart2        dd      ?
bytesPart2      dd      ?

timeValue       dd      0.0
oneSec          dd      0.00002267573
ten             dd      10
maxValue        dd      2000  
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
    soundMsg, time

    mov     eax, [soundMsg]
    fld1                     ; 1 
    fld     [time]           ; t, 1
    fmul    [eax+Message.msgNote+Note.freq]           ; t*freq, 1
    fprem                    ; phase, 1
    fstp    st1              ; phase

    movzx   eax, word[eax+Message.msgNote+Note.instrumentOffset]
    add     eax, instruments
    movzx   eax, word[eax+Instrument.oscType]
    

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
    FPU_CMP                   ; 
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
    fimul   [maxValue]

    xor eax, eax
    push    eax
    fistp   word[esp]
    pop     eax


.Return:
    ret
endp

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
    soundMsg

    invoke HeapAlloc, [hHeap], 8, sizeof.DoublyLinkedList
    mov edx, [soundMsg]
    mov [eax+DoublyLinkedList.data], edx

    mov edx, [msgListHead]    
    mov [eax+DoublyLinkedList.next], edx

    ; CAN BE REMOVED: THE ALLOCATED MEMORY IS INITIALIZED WITH ZERO
    mov [eax+DoublyLinkedList.prev], LIST_NONE
    cmp edx, LIST_NONE
    je .return
    mov [edx+DoublyLinkedList.prev], eax
.return:
    mov [msgListHead], eax
    ret
endp

proc Sound.RemoveMessage,\
    soundMsgNode
    
    mov eax, [soundMsgNode]
    cmp eax, [msgListHead]
    je .isHead

    mov edx, [eax+DoublyLinkedList.prev]
    mov ecx, [eax+DoublyLinkedList.next]
    mov [edx+DoublyLinkedList.next], ecx
    push ecx
    cmp ecx, LIST_NONE
    je .return
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
.linear:
    ; yikes
    jmp     .store
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
    env, soundMsg, time

    mov         eax, [soundMsg]
    fld         [time]                      ; t
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

proc Sound.PlayMsgList,\
    time

    locals
        tempMultiplier      dd      ?
    endl

    mov edx, [msgListHead]
    xor eax, eax

.looper:
    cmp edx, LIST_NONE
    je .return
    push eax
    push edx


    mov ecx, [edx+DoublyLinkedList.data]
    ; ecx has the pointer to the message
    ;stdcall     Sound.GenSample, msg, [time]
    ;stdcall     Sound.GetADSRAmp, ecx, [time]
    ;multiply the acquired values and get the needed value

    push ecx
    stdcall     Sound.GenSample, ecx, [time]
    pop         ecx
    push        eax


    movzx       eax, word[ecx+Message.msgNote+Note.instrumentOffset]
    add         eax, instruments+Instrument.env
    stdcall     Sound.GetADSRAmp, eax, ecx, [time]
    cmp         eax, DELETE_FLAG
    je          .delete



    fild        word[esp]               ; sample
    push        eax
    fmul        dword[esp]              ; resAmp
    pop         eax
    fistp       word[esp]
    pop         eax


    pop edx
    mov edx, [edx+DoublyLinkedList.next]

    pop ecx
    add eax, ecx

    jmp         .looper
.delete:
;    pop eax
;    pop eax
;    stdcall Sound.RemoveMessage, eax
    pop eax
    stdcall     Sound.RemoveMessage
    ; eax has the address of a next node
    mov edx, eax

    pop eax
    jmp .looper
.return:
    ret
endp


proc Sound.MessagePollAdd

    mov         ecx, [messagesPtr]
.addMsgs:
    cmp         ecx, msgEnd
    je          .msgsAdded
    fld         [timeValue]                      ; t
    fld         [ecx+Message.msgTrigger]         ; triggerTime, t
    FPU_CMP
    jae         .msgsAdded
    push        ecx
    stdcall     Sound.NewMessage, ecx
    pop         ecx
    add         ecx, sizeof.Message
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
    mov     edx, [soundMsg]
    mov     [eax+DoublyLinkedList.data], edx

    mov     edx, [seqMain+Sequencer.msgListHead]
    mov     [eax+DoublyLinkedList.next], edx
    cmp     edx, LIST_NONE
    je      .finishMessage
    mov     [edx+DoublyLinkedList.prev], eax
.finishMessage:
    mov     [seqMain+Sequencer.msgListHead], eax

; creating new pattern node
    invoke  HeapAlloc, [hHeap], 8, sizeof.DoublyLinkedList
    mov     edx, [pattern]
    mov     [eax+DoublyLinkedList.data], edx

    mov     edx, [seqMain+Sequencer.patternListHead]
    mov     [eax+DoublyLinkedList.next], edx

    cmp     edx, LIST_NONE
    je      .finishPattern
    mov     [edx+DoublyLinkedList.prev], eax
.finishPattern:
    mov     [seqMain+Sequencer.patternListHead], eax

    ret
endp


proc Sound.CreateMsgCopy uses edi esi,\
    soundMsg

    invoke  HeapAlloc, [hHeap], 8, sizeof.Message
    push    eax
    mov     edi, eax
    mov     esi, [soundMsg]
    mov     ecx, sizeof.Message
.looper:
    lodsb
    stosb
    loop .looper
    pop     eax

    ret
endp

proc Sound.UpdateSequencer

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
    cmp     ecx, LIST_NONE
    je      .msgsEnded
    push    ecx
    push    eax
    push    edx

    mov     eax, [eax+DoublyLinkedList.data]
    bt      eax, edx
    jnc     .notNewMessage
    ;mov     eax, [eax+DoublyLinkedList.data]
    ;stdcall Sound.CreateMsgCopy, eax
    stdcall  Sound.CreateMsgCopy, [ecx+DoublyLinkedList.data]
    mov      ecx, [timeValue]
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

    
; initialization of sequencer
    mov         ecx, seqMain
    mov         edx, 60.0
    FPU_LD      edx                             ; 60.0
    fdiv        [ecx+Sequencer.tempo]           ; dtOneBeat
    movzx       eax, [ecx+Sequencer.beats]
    push        eax
    fidiv       dword[esp]                      ; dt
    pop         eax
    fstp        [ecx+Sequencer.timeOneBeat]     ; 
    pop         edx
    mov         dl, byte[ecx+Sequencer.beats]
    mov         al, byte[ecx+Sequencer.subBeats]
    imul        dl
    mov         word[ecx+Sequencer.totalBeats], ax
    nop
    stdcall     Sound.AddSequencer, testMsg, 7555h
    stdcall     Sound.StartTimeSequencer, 0.0

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




    ; add messages if necessary
    stdcall     Sound.MessagePollAdd

    stdcall     Sound.UpdateSequencer

    mov         edx, [timeValue]
    stdcall     Sound.PlayMsgList, edx
    stosw
    stosw   

    fld         [timeValue]
    fadd        [oneSec]
    fstp        [timeValue]
    pop         ecx
    loop .looper


    cominvk dsb, Unlock, [ptrPart1], [bytesPart1], [ptrPart2], [bytesPart2]
    
    cominvk dsb, Play, 0, 0, 0
    ret
endp