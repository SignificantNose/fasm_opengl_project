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
msg3            UnprocessedMessage      <165.0,6.0,0.0>, INSTR_SAW

msgEnd:

messagesPtr     dd      messages

seqMain         Sequencer       <LIST_NONE,LIST_NONE,0>, <LIST_NONE,LIST_NONE,0>, 60.0, 0.0, 0.0, 16, 4, 4, 0
;testMsg         Message <660.0,INSTR_HIHAT>, 0.1, 0.1


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
maxValue        dd      4000  
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
    
    ; try something else, like shifted triangle. The calculation will be easier
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

proc Sound.NewMessage,\
    unprocMsg

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

proc Sound.interpolatePhase,\
    interpType, phase

    mov     eax, [interpType]

    
    fld     [phase]             ; phase
    JumpIf  INTERP_LINEAR, .linear
    JumpIf  INTERP_REVERSELINEAR, .reverseLinear
    JumpIf  INTERP_SQUARE, .square
    JumpIf  INTERP_REVERSESQUARE, .reverseSquare
    JumpIf  INTERP_BISQUARE, .bisquare
    JumpIf  INTERP_TRIANGLE, .triangle
    JumpIf  INTERP_SINE, .sine


    xor eax, eax
    fstp    st0
    jmp .return
;.linear:
;    ; yikes
;    jmp     .store
.reverseSquare:
    fchs                        ; -phase
    fld1                        ; 1, -phase
    faddp                       ; reversePhase
.square:
    fmul    [phase]             ; phase^2
    jmp     .store
.bisquare:
    fmul    [phase]             ; phase^2
    fld     st0                 ; phase^2, phase^2
    fmulp                       ; phase^4

    jmp     .store
.triangle:
    mov     eax, 2
    push    eax
    fimul   dword[esp]          ; 2*phase
    pop     eax
    fld1                        ; 1, 2*phase
    fsubp                       ; 2*phase-1
    fabs                        ; |2*phase-1|
    fchs                        ; -|2*phase-1|
    fld1                        ; 1, -|2*phase-1|
    faddp                       ; 1-|2*phase-1|

    jmp     .store
.sine:
    fldpi                       ; pi, phase
    fidiv   [two]               ; pi/2, phase
    fmulp                       ; phase*pi/2
    fsin                        ; sin(phase*pi/2)
    jmp     .store
.reverseLinear:
    fchs                        ; -phase
    fld1                        ; 1, -phase
    faddp                       ; reversePhase
.linear:
.store:
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
    movzx   eax, byte[eax+EnvelopeADSR.interpAttack]
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
    movzx       eax, byte[eax+EnvelopeADSR.interpDecay]
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
    movzx       eax, byte[eax+EnvelopeADSR.interpRelease]


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


proc Sound.GenMessageSamples,\
    soundMsg, oscList
    locals 
        smplRight       dd      0.0
        smplLeft        dd      0.0
    endl

    mov     ecx, [soundMsg]
    mov     eax, [oscList]
.loopOscs:    
    cmp     eax, LIST_NONE
    je      .return

    push    eax
    push    ecx
    ; probably will use 2 registers to return: eax and edx
    mov     ecx, [ecx+DoublyLinkedList.data]
    stdcall Sound.GetOscSamples, [eax+DoublyLinkedList.data], [ecx+Message.msgFreq], [ecx+Message.msgTrigger]
    
    
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
.return:
    mov     eax, [smplRight]
    mov     edx, [smplLeft]
    ret
endp

; returns the sample for current instrument,
; that is: two float values representing the
; sum of all oscillators for each message 
; with the ADSR applied
;
; the float values are returned in 
; edx (L) and eax (R) registers
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


;    push    edx

;    fldz                ; 0
;    fst     [smplLeft]  ; 0
;    fstp    [smplRight] ;

    mov     eax, [edx+Instrument.oscListPtr]

    stdcall Sound.GenMessageSamples, ecx, eax
; ADSR Stage:
    
;    pop     edx
    
    pop     ecx
    push    eax     ; right sample
    push    edx     ; left sample
    push    ecx
    mov     edx, [instr]
    stdcall Sound.GetADSRAmp, [edx+Instrument.envelope], [ecx+DoublyLinkedList.data]
    pop     ecx
    cmp     eax, DELETE_FLAG
    je      .delete


    ; right now left sample is on top
;    push    eax
;    fld     [smplLeft]  ; left
;    fmul    dword[esp]  ; resLeft
;    fadd    [resLeft]   ; newLeft
;    fstp    [resLeft]
;
;    fld     [smplRight] ; right
;    fmul    dword[esp]  ; resRight
;    fadd    [resRight]  ; newRight
;    fstp    [resRight]
;    pop     eax

    fld     dword[esp]  ; leftSample
    pop     edx         ; leftSample
    fld     dword[esp]  ; rightSample, leftSample
    pop     edx
    push    eax
    fmul    dword[esp]  ; resRight, leftSample
    fstp    [resRight]  ; leftSample
    fmul    dword[esp]  ; leftRes
    fstp    [resLeft]
    pop     eax






    mov     ecx, [ecx+DoublyLinkedList.next]

    pop     edx
    jmp     .loopMsgs

.delete:
    pop     eax
    pop     edx
    stdcall Sound.RemoveInstrMessage, [instr], ecx
    ;mov     ecx, eax
    xchg    ecx, eax

    pop     edx
    jmp     .loopMsgs
.return:
;    push    eax
;    fld     [resLeft]       ; resLeft
;    fimul   [maxValue]      ; intResLeft
;    ; will have to think about it
;    fistp   dword[esp]
;    pop     eax 
;
;    shl     eax, 16
;
;    push    eax
;    fld     [resRight]      ; resRight
;    fimul   [maxValue]      ; intResRight
;    fistp   dword[esp]
;    pop     edx
;    and     edx, 0xFFFF
;    or      eax, edx
    push    edx
    fld     [resLeft]   ; resLeft
    fstp    dword[esp]  ; 
    pop     edx
    push    eax         
    fld     [resRight]  ; resRight
    fstp    dword[esp]  ;
    pop     eax

    ret
endp

proc Sound.PlayMsgList

    mov     ecx, instruments
    xor     eax, eax
.looper:
    cmp     ecx, instrumentsEnd
    je      .return
    push    ecx
    push    eax

    push    ecx
    ; instruments must return float values, so that the effects can be applied
    stdcall Sound.GetInstrumentSample, ecx
    ; return values:
    ; edx - left sample 
    ; eax - right sample
    ; samples have unison applied (if present) and ADSR as well
    pop     ecx
    mov     ecx, [ecx+Instrument.filter]
    jecxz   .noFilter


    
    ; the pushes can be optimized
    push    ecx
    push    eax
    push    edx

    mov     edx, ecx
    mov     ecx, [ecx+InstrFilter.cutoffFreqLFO]
    jecxz   .noFilterLFO



    push    edx
    stdcall Sound.LFOGetValue, ecx, 0.0
    stdcall Sound.CalcButterworthCoeffs, eax    ;, filter
    ;push    eax
    ;add     eax, InstrFilter.leftSamples
    ;push    eax
    ;add     eax, InstrFilter.coeffs-InstrFilter.leftSamples
    ;push    eax
    ;stdcall Sound.FilterRecalculatePrev ; , eax+InstrFilter.coeffs, eax+InstrFilter.leftSamples
    ;pop     eax
    ;add     eax, InstrFilter.rightSamples
    ;push    eax 
    ;add     eax, InstrFilter.coeffs-InstrFilter.rightSamples
    ;push    eax
    ;stdcall Sound.FilterRecalculatePrev ; , eax+InstrFilter.coeffs, eax+InstrFilter.rightSamples


.noFilterLFO:

    pop     edx
    pop     eax
    pop     ecx

    

    push    ecx
    push    eax
    ;stdcall Sound.FilterProcessChannel, edx, ecx+InstrFilter.coeffs, ecx+InstrFilter.rightSamples
    add     ecx, InstrFilter.leftSamples
    push    ecx
    add     ecx, InstrFilter.coeffs-InstrFilter.leftSamples
    push    ecx
    push    edx
    stdcall Sound.FilterProcessChannel
    ; filter applied for left channel sample
    
    pop     edx
    pop     ecx
    
    ; eax here is for the left channel
    push    eax
    
    ;stdcall Sound.FilterProcessChannel, edx, ecx+InstrFilter.coeffs, ecx+InstrFilter.leftSamples
    add     ecx, InstrFilter.rightSamples
    push    ecx
    add     ecx, InstrFilter.coeffs-InstrFilter.rightSamples
    push    ecx
    push    edx
    stdcall Sound.FilterProcessChannel
    ; filter applied for right channel sample
    
    pop     edx

.noFilter:


    push    eax
    fld     dword[esp]      ; sample
    fimul   [maxValue]      ; resSample
    fistp   dword[esp]      ; 
    pop     eax 

    ;mov     edx, eax
    push    edx 
    fld     dword[esp]      ; sample
    fimul   [maxValue]      ; resSample
    fistp   dword[esp]      ;
    pop     edx


    pop     ecx 
    add     ax, cx
    rol     eax, 16
    rol     ecx, 16
    add     dx, cx
    add     ax, dx 
    ; i guess, the order of the elements in the buffer are reversed, as:
    ; rol     eax, 16
    pop     ecx
    add     ecx, sizeof.Instrument
    jmp     .looper
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
    ;stdcall     Sound.AddOscillator, oscSaw, instrSaw
    invoke      HeapAlloc, [hHeap], 8, sizeof.InstrFilter
    ;mov         [instrSaw+Instrument.filter], eax
    ;mov         [eax+InstrFilter.cutoffFreqLFO], LFOCutoff
    ;stdcall     Sound.CalcButterworthCoeffs, 500.0, eax
    
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