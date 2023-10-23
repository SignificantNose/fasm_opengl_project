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


myOsc           dd      ?

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
    osc, time

    locals
        timeMem     dd  ?
        freqMem     dd  ?
        result      dw  ?
    endl

    mov     edx, [osc]
    movzx   eax, byte[edx+Oscillator.oscType]
    mov     ecx, [edx+Oscillator.freq]

    mov edx, [time]
    mov [timeMem], edx
    mov [freqMem], ecx


    JumpIf OSC_SINE, .sine
    JumpIf OSC_SQUARE, .square
    JumpIf OSC_SAW, .saw
    JumpIf OSC_TRIANGLE, .triangle
    JumpIf OSC_NOISE, .noise
    xor eax, eax
    jmp .Return

.sine:
    fld     [timeMem]           ; t
    fmul    [freqMem]           ; t*freq
    fsin                        ; sin(t*freq)
    jmp .getResult
.square:
    fld     [timeMem]           ; t
    fmul    [freqMem]           ; t*freq
    fsin                        ; sin(t*freq)
    fldz                        ; 0, sin(t*freq)
    fcomip  st0, st1            ; sin(t*freq)
    fstp    st0
    fld1
    jae @F                      ; 0>sin
    fchs
@@:
    jmp .getResult
.saw:
    jmp .getResult
.triangle:

    fld     [timeMem]           ; t
    fmul    [freqMem]           ; t*freq
    fsin                        ; sin(t*freq)
    fld     st0                 ; sin, sin
    fmul    st0, st0            ; sin^2, sin
    fld1                        ; 1, sin^2, sin
    fsubrp                      ; 1-sin^2, sin
    fsqrt                       ; sqrt(1-sin^2), sin
    fpatan                      ; arctg == arcsin
    fld1                        ; 1, arcsin
    fld1                        ; 1, 1, arcsin
    faddp                       ; 2, arcsin
    fmulp                       ; 2*arcsin
    fldpi                       ; pi, 2*arcsin
    fdivp                       ; 2*arcsin/pi
    jmp .getResult
.noise:

.getResult:
    fimul   [maxValue]
    fistp   word[result] 
    mov     ax, [result]


.Return:
    ret
endp

proc Sound.CreateOsc, type, freqHz
    invoke      HeapAlloc, [hHeap], 8, sizeof.Oscillator
    push        eax

    stdcall     Sound.Hz2Angular, [freqHz]
    mov         ecx, eax

    pop         eax
    mov         [eax+Oscillator.freq], ecx    

    mov         cx, word[type]
    mov         [eax+Oscillator.oscType], cx
    ret
endp

proc Sound.init uses edi ecx
    invoke      GetDesktopWindow
    mov         [hDskWnd], eax          ; do I need it though?
    invoke      DirectSoundCreate8, NULL, dsc, NULL

    cominvk     dsc, SetCooperativeLevel, [hDskWnd], DSSCL_PRIORITY
    cominvk     dsc, CreateSoundBuffer, dsbd, dsb, NULL
    cominvk     dsb, Lock, 0, [blockSize], ptrPart1, bytesPart1, ptrPart2, bytesPart2, 0

    stdcall     Sound.CreateOsc, OSC_TRIANGLE, 440.0
    mov         [myOsc], eax

    mov         edi, [ptrPart1]
    mov         ecx, BUFFERSIZE_BYTES/4
.looper:
    push        ecx
    stdcall     Sound.GenSample, [myOsc], [timeValue]
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