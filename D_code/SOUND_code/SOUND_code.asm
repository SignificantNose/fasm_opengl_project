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


; the interfaces cannot be declared in SOUND_structs, that's why:
dsc             IDirectSound8                      
dsb             IDirectSoundBuffer8   
track1Buffer    IDirectSoundBuffer8   
track2Buffer    IDirectSoundBuffer8
lpDSNotify    IDirectSoundNotify

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


proc Sound.interpolatePhase,\
    interpType, phase

    mov     eax, [interpType]

    
    fld     [phase]             ; phase
    test    eax, INTERP_REVERSE 
    jz      .notReverse
    fchs                        ; -phase
    fld1                        ; 1, -phase
    faddp                       ; reversePhase
    fst     [phase]
    xor     eax, INTERP_REVERSE
.notReverse:

    JumpIf  INTERP_LINEAR, .linear
    JumpIf  INTERP_SQUARE, .square
    JumpIf  INTERP_CUBIC, .cubic
    JumpIf  INTERP_QUADRA, .quadra
    JumpIf  INTERP_TRIANGLE, .triangle
    JumpIf  INTERP_SINE, .sine

    xor eax, eax
    fstp    st0
    jmp .return
.square:
    fmul    [phase]             ; phase^2
    jmp     .store
.cubic: 
    fmul    [phase]             ; phase^2
    fmul    [phase]             ; phase^3 
    jmp     .store
.quadra:
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
.linear:
.store:
    push    eax                  ; 1 B
    FPU_STP eax                  ; 4 B   

.return:
    ret
endp

proc Sound.ADSAmp,\
    env, dt

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
    fsub        [eax+InstrumentMessage.msgData+MessageData.msgTrigger]    ; dt
    fld         st0                         ; dt, dt
    fsub        [eax+InstrumentMessage.msgData+MessageData.msgDuration]   ; dt-tDur, dt
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
    stdcall     Sound.ADSAmp, [env], [eax+InstrumentMessage.msgData+MessageData.msgDuration]
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
    
    stdcall     Sound.ADSAmp, [env], edx     

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


; routine for generating sound for current
; sound message (the instrument has an oscillator
; list, which allows for multiple oscillators
; to be present in the instrument; the 
; routine generates sound that is the sum of
; the effect of each of the messages separately)
proc Sound.GenMessageSamples uses esi,\
    soundMsg, oscList
    locals 
        smplRight       dd      0.0
        smplLeft        dd      0.0
    endl

    mov     esi, [soundMsg]
    mov     esi, [esi+DoublyLinkedList.data]
    mov     eax, [oscList]
.loopOscs:    
    cmp     eax, LIST_NONE
    je      .return

    push    eax
    ; probably will use 2 registers to return: eax and edx

    stdcall Sound.GetOscSamples, [eax+DoublyLinkedList.data], esi
    
    FPU_LD  eax         ; sampleRight
    fadd    [smplRight] ; newSampleRight
    fstp    [smplRight]
    pop     eax
    FPU_LD  edx         ; sampleLeft
    fadd    [smplLeft]  ; newSampleLeft
    fstp    [smplLeft] 
    pop     edx

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
    fadd    [resRight]
    fstp    [resRight]  ; leftSample
    fmul    dword[esp]  ; leftRes
    fadd    [resLeft]
    fstp    [resLeft]
    pop     eax






    mov     ecx, [ecx+DoublyLinkedList.next]

    pop     edx
    jmp     .loopMsgs

.delete:
    pop     eax
    pop     edx
    stdcall SoundMsg.RemoveInstrMessage, [instr], ecx
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

; routine for acquiring the integer representation
; of the current sample (meaning the sample that is
; the sum of all the samples acquired from all the
; instruments and their message polls). returns the
; value in eax: higher 16 bits are for right sample,
; and lower 16 bits are for left sample
proc Sound.PlayMsgList uses esi edi,\
    pTrackInstrList

    mov     esi, [pTrackInstrList]
    mov     ecx, [esi + TrackInstrumentList.InstrCount]
    mov     esi, [esi + TrackInstrumentList.InstrDefinerArray]
    xor     eax, eax

    jecxz   .return 
.looper:
    push    ecx     ; iterator
    
    ; total sum in 4 bytes
    push    eax     
    mov     edi, [esi + InstrDefiner.pInstrument]

    stdcall Sound.GetInstrumentSample, edi
    ; return values:
    ; edx - left sample 
    ; eax - right sample
    ; samples have unison applied (if present) and ADSR as well

    mov     ecx, [edi + Instrument.filter]
    jecxz   .noFilter

    ; stdcall Filter.ApplyToSamples, edx, eax, ecx
    stdcall Filter.ApplyToSamples, edx, eax, edi 
    ; return values:
    ; edx - left sample 
    ; eax - right sample

.noFilter:

    mov     ecx, [edi + Instrument.reverb]
    jecxz   .noReverb
    stdcall Reverb.ApplyToSamples, edx, eax, ecx

.noReverb:

    push    eax 
    fld     dword[esp]                      ; sample
    fimul   [maxValue]                      ; resSample
    fmul    [edi + Instrument.masterValue]  ; masteredSample
    fistp   dword[esp]                      ; 
    pop     eax 

    push    edx 
    fld     dword[esp]                      ; sample
    fimul   [maxValue]                      ; resSample
    fmul    [edi + Instrument.masterValue]  ; masteredSample
    fistp   dword[esp]                      ; 
    pop     edx 


    pop     ecx 
    add     ax, cx 
    rol     eax, 16
    rol     ecx, 16
    add     dx, cx 
    add     ax, dx 

    pop     ecx     ; iterator
    add     esi, sizeof.InstrDefiner
    loop    .looper 
.return: 
    ret
endp

; routine for clearing the message polls 
; of the instruments, freeing the memory,
; removing the effect of the reverberation,
; filter effect and re-initializing the instrument
proc Sound.ClearInstruments uses esi edi,\
    pTrackInstrList

    mov     esi, [pTrackInstrList]
    mov     ecx, [esi + TrackInstrumentList.InstrCount]
    mov     esi, [esi + TrackInstrumentList.InstrDefinerArray]

    jecxz   .return 
.looper:
    push    ecx     ; iterator
    mov     edi, [esi + InstrDefiner.pInstrument]


.looperMsgPtrs:
    mov     ecx, [edi + Instrument.msgPollPtr]
    jecxz   .endLooperMsgPtrs
    stdcall SoundMsg.RemoveInstrMessage, edi, ecx 
    jmp     .looperMsgPtrs
.endLooperMsgPtrs:    

    mov     ecx, [edi + Instrument.filter]
    jecxz   .noFilter 
    stdcall Filter.ClearFilter, ecx
.noFilter:

    mov     ecx, [edi + Instrument.reverb]
    jecxz   .noReverb 
    stdcall Reverb.ClearReverberator, ecx 
.noReverb:
    pop     ecx     ; iterator
    add     esi, sizeof.InstrDefiner
    loop    .looper

.return:
    ret 
endp



proc Sound.Init uses edi ecx
    invoke      GetDesktopWindow
    mov         [hDskWnd], eax          ; do I need it though?
    invoke      DirectSoundCreate8, NULL, dsc, NULL

    cominvk     dsc, SetCooperativeLevel, [hDskWnd], DSSCL_PRIORITY
    
; initialization of oscillators
    ;stdcall     Sound.AddOscillator, oscSine, instrSine
    ;stdcall     Sound.AddOscillator, oscSaw, instrSaw
    ;stdcall     Sound.AddOscillator, oscSaw, instrSaw


    stdcall     Sound.AddOscillator, oscNoise, instrHihat

    stdcall     Sound.AddOscillator, oscSynthSaw, instrSynth
    stdcall     Sound.AddOscillator, oscSine, instrSynth

    stdcall     Sound.AddOscillator, oscSaw, instrBass

    stdcall     Sound.AddOscillator, oscSawPads, instrPads
    stdcall     Filter.Initialize, instrPads, FILTERCOEF_CONST, 290.0

; sad that I hadn't thought of adjusting the octave or the pitch
; of the sound. only through LFO.
    stdcall     Sound.AddOscillator, oscTomSine, instrTom 
    stdcall     Sound.AddOscillator, oscNoise, instrTom 

    stdcall     Sound.AddOscillator, oscKickSine, instrKick

    stdcall     Sound.AddOscillator, oscSnareNoise, instrSnareTail
    stdcall     Reverb.GenerateReverberator, 0.24, 0.55     ; oh I love it
    mov         [instrSnareTail + Instrument.reverb], eax 
    
    stdcall     Sound.AddOscillator, oscSnareSine, instrSnareBody

    stdcall     Sound.AddOscillator, oscKeySaw, instrKey
    stdcall     Reverb.GenerateReverberator, 0.2, 0.5
    mov         [instrKey + Instrument.reverb], eax 

    stdcall     Sound.AddOscillator, oscLaserSquare, instrLaser

    stdcall     Filter.Initialize, instrSynth, FILTERCOEF_CONST, 2200.0
    stdcall     Filter.Initialize, instrBass, FILTERCOEF_DYNAMIC, LFOCutoff

    stdcall     Reverb.GenerateReverberator, 0.43, 0.5
    mov         [instrSynth + Instrument.reverb], eax 

; ; initialization of sequencer
; ;    mov         ecx, seqMain
; ;    mov         edx, 60.0
; ;    FPU_LD      edx                             ; 60.0
; ;    fdiv        [ecx+Sequencer.tempo]           ; dtOneBeat
; ;    movzx       eax, [ecx+Sequencer.beats]
; ;    push        eax
; ;    fidiv       dword[esp]                      ; dt
; ;    pop         eax
; ;    fstp        [ecx+Sequencer.timeOneBeat]     ; 
; ;    pop         edx
; ;    mov         dl, byte[ecx+Sequencer.beats]
; ;    mov         al, byte[ecx+Sequencer.subBeats]
; ;    imul        dl
; ;    mov         word[ecx+Sequencer.totalBeats], ax
; ;    stdcall     Sound.AddSequencer, testMsg, 7555h
; ;    stdcall     Sound.StartTimeSequencer, 0.0

; initialization of a global variable for one second
    mov         eax, 44100
    push        eax
    fld1                    ; 1
    fidiv       dword[esp]  ; dt
    fstp        [oneSec]    ;
    pop         eax


    ret
endp