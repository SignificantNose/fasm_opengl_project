DSBPN_OFFSETSTOP     equ    0xFFFFFFFF
INFINITE             equ    0xFFFFFFFF
DSSCL_NORMAL         equ    1
DSSCL_PRIORITY       equ    2
DSSCL_EXCLUSIVE      equ    3
DSSCL_WRITEPRIMARY   equ    4
DSBCAPS_GLOBALFOCUS  equ    $8000
DSBCAPS_CTRLPOSITIONNOTIFY equ  $100  


STATE_OFF            equ    0
STATE_ON             equ    1
DELETE_FLAG          equ    0xFFFFFFFF
LIST_NONE            equ    0
FRDISC_VALUE         equ    44100
BUFFERSIZE_BYTES     equ    2*FRDISC_VALUE*2* 8 

hDskWnd              dd     ?
ptrPart1             dd     ?
bytesPart1           dd     ?
ptrPart2             dd     ?
bytesPart2           dd     ?
frDisc               dd     FRDISC_VALUE
blockSize            dd     BUFFERSIZE_BYTES


timeValue            dd     0
currTime             dd     0.0
oneSec               dd     0.00002267573
ten                  dd     10
maxValue             dd     4000  
randNoise            dd     2000
two                  dd     2
three                dd     3
four                 dd     4
triangleTemp         dd     0.25

struct GUID
       Data1             dd     ?
       Data2             dw     ?
       Data3             dw     ?
       Data4             db     8 dup(?)
ends       

struct DSBUFFERDESC
       dwSize dd ?
       dwFlags dd ?
       dwBufferBytes dd ?
       dwReserved dd ?
       lpwfxFormat dd ?
       guid3DAlgorithm  GUID
ends  

struct WAVEFORMATEX
       wFormatTag dw ?
       nChannels dw ?
       nSamplesPerSec dd ?
       nAvgBytesPerSec dd ?
       nBlockAlign dw ?
       wBitsPerSample dw ?
       cbSize dw ?
ends  

struct DSBPOSITIONNOTIFY
       dwOffset      dd     ?
       hEventNotify  dd     ?
ends 

IID_IDirectSoundNotify8     GUID   0xB0210783, 0x89CD, 0x11D0, <0xAF, 0x8, 0x0, 0xA0, 0xC9, 0x25, 0xCD, 0x16>

dsbd            DSBUFFERDESC sizeof.DSBUFFERDESC, DSBCAPS_GLOBALFOCUS or DSBCAPS_CTRLPOSITIONNOTIFY,\
                0, 0, mywaveformat, <0,0,0,0>      
mywaveformat    WAVEFORMATEX 1, 2, 44100, 4*44100, 4, 16, 0

PositionNotify  DSBPOSITIONNOTIFY   DSBPN_OFFSETSTOP, ?