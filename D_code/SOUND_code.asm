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
instrNoise     Instrument      <0,0,0,0,0>, OSC_NOISE
INSTR_NOISE = ($-instruments)/sizeof.Instrument-1

instrSine      Instrument      <0,0,0,0,0>, OSC_SINE
INSTR_SINE = ($-instruments)/sizeof.Instrument-1


LIST_NONE       equ     0
msgListHead     dd      LIST_NONE


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
    instrument, time, freq

    ; need to get rid of it some time
    locals
        result      dw  ?
        randBuffer  dd  ?
        phaseBuffer dd  ?
    endl


    ; transfer it to the other function later
    fld1                     ; 1 
    fld     [time]           ; t, 1
    fmul    [freq]           ; t*freq, 1
    fprem                    ; phase, 1
    fstp    st1              ; phase

    mov     edx, [instrument]
    movzx   eax, word[edx+Instrument.oscType]

    JumpIf OSC_SINE, .sine
    JumpIf OSC_SQUARE, .square
    JumpIf OSC_SAW, .saw
    JumpIf OSC_TRIANGLE, .triangle
    JumpIf OSC_NOISE, .noise
    xor eax, eax
    jmp .Return

.sine:  
    ; it's more convenient to do it in place, have to think about it
    fstp    [phaseBuffer]
    stdcall Sound.Hz2Angular, [phaseBuffer]
    mov     [phaseBuffer], eax
    fld     [phaseBuffer]    ; 2*pi*phase
    fsin                     ; sin(2*pi*phase)
    jmp .getResult
.square:
    fstp    [phaseBuffer]
    stdcall Sound.Hz2Angular, [phaseBuffer]
    mov     [phaseBuffer], eax
    fld     [phaseBuffer]    ; 2*pi*phase
    fsin                     ; sin(2*pi*phase)
    fldz                     ; 0, sin    
    FPUCMP                   ; 
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

    nop
    fimul    [four]          ; 4*t
    fld      st0             ; 4*t, 4*t
    fld1                     ; 1, 4*t, 4*t
    FPUCMP                   ; 4*t
    ja      .getResult
    fld      st0             ; 4*t, 4*t
    fild      [three]        ; 3, 4*t, 4*t
    FPUCMP                   ; 4*t
    jb      .finalCase
    fchs                     ; -4*t
    fiadd   [two]            ; 2-4*t
    jmp     .getResult
.finalCase:
    fisub    [four]          ; 4*t-4

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
    stdcall     Rand.GetRandomInBetween, 0, [randNoise]
    mov         [randBuffer], eax
    fild        [randBuffer]          ; x = [0,max]
    fild        [randNoise]           ; max, x
    fidiv       [two]                 ; max/2, x
    fsubp                             ; x = [-max/2,max/2]
    fidiv       [randNoise]           ; x = [-1/2, 1/2]
    fimul       [two]                 ; x = [-1,1]
    



.getResult:
    fimul   [maxValue]
    fistp   word[result] 
    mov     ax, [result]


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



; ADSR-get
proc Sound.GetAmplitude,\
    envelope, time

    locals
        envOnTime   dd  ?
    endl

    cmp     [eax+EnvelopeADSR.state], STATE_OFF
    je .off

    mov     eax, [envelope]
    mov     edx, [eax+EnvelopeADSR.onTime]
    mov     [envOnTime], edx

    fld     [time]                  ; time
    fsub    [envOnTime]             ; envTime

    ; make macro for comparing float values


    jmp .return

.off:


.return: 

    ret
endp

proc Sound.NewMessage,\
    pNote

    invoke HeapAlloc, [hHeap], 8, sizeof.DoublyLinkedList
    mov edx, [pNote]
    mov [eax+DoublyLinkedList.data], edx
    mov edx, [msgListHead]
    
    mov [eax+DoublyLinkedList.next], edx

    ; CAN BE REMOVED: THE ALLOCATED MEMORY IS INITIALIZED WITH ZERO
    mov [eax+DoublyLinkedList.prev], LIST_NONE
    cmp edx, LIST_NONE
    je .newListHead
    mov [edx+DoublyLinkedList.prev], eax
.return:
    mov [msgListHead], eax
    ret
endp

proc Sound.RemoveMessage,\
    msgNode
    
    mov eax, [msgNode]
    cmp eax, [msgListHead]
    je .isHead

    mov edx, [eax+DoublyLinkedList.prev]
    mov ecx, [eax+DoublyLinkedList.next]
    mov [edx+DoublyLinkedList.next], ecx
    cmp ecx, LIST_NONE
    je .return
    mov [ecx+DoublyLinkedList.prev], edx
    jmp .return
.isHead:
    mov edx, [eax+DoublyLinkedList.next]
    mov [msgListHead], edx

.return:
    invoke HeapFree, [hHeap], 0, eax
    ret
endp


proc Sound.PlayMsgList

    mov eax, [msgListHead]

.looper:
    cmp eax, LIST_NONE
    je .return

    ; if the time has passed, remove it from the poll

    push eax
    stdcall Sound.play, eax
    pop eax


    mov eax, [eax+SoundMsg.next]
    jmp .looper
.return:
    ret
endp

proc Sound.init uses edi ecx
    invoke      GetDesktopWindow
    mov         [hDskWnd], eax          ; do I need it though?
    invoke      DirectSoundCreate8, NULL, dsc, NULL

    cominvk     dsc, SetCooperativeLevel, [hDskWnd], DSSCL_PRIORITY
    cominvk     dsc, CreateSoundBuffer, dsbd, dsb, NULL
    cominvk     dsb, Lock, 0, [blockSize], ptrPart1, bytesPart1, ptrPart2, bytesPart2, 0

    mov         edi, [ptrPart1]
    mov         ecx, BUFFERSIZE_BYTES/4
.looper:
    push        ecx
    stdcall     Sound.GenSample, instrSine, [timeValue], 440.0
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