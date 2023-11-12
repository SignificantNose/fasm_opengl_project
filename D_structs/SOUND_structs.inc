struct DoublyLinkedList
       next              dd     ?
       prev              dd     ?
       data              dd     ?
ends
struct EnvelopeADSR
       attackTime        dd     ?
       decayTime         dd     ?
       releaseTime       dd     ?

       sustainAmpl       dd     ?
       startAmpl         dd     ?  

       interpAttack      dw     ?
       interpDecay       dw     ?
       interpRelease     dw     ?
ends

struct Instrument
       envelope          dd     ? 
       oscListPtr        dd     ?       
       msgPollPtr        dd     ?        
       filter            dd     ?
       reverb            db     ?    ;????
       LFO               dd     ?    ; maybe it must have the address of the modifiable value...
ends


struct Message
       msgFreq           dd     ?
       msgDuration       dd     ?
       msgTrigger        dd     ?
ends
struct UnprocessedMessage
       msgData           Message
       instrNumber       db     ?
ends

struct Sequencer
       msgListHead       DoublyLinkedList
       patternListHead   DoublyLinkedList
       tempo             dd     ?
       timeElapsed       dd     ?
       timeOneBeat       dd     ?

       totalBeats        dw     ?
       beats             db     ?
       subBeats          db     ?
       currentBeat       dw     ?

ends

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

FILTER_NONE          = 0
FILTER_LOPASS        = 1
FILTER_HIPASS        = 2
FILTER_BANDPASS      = 3



EnvRegular    EnvelopeADSR     0.5,0.5,0.5,0.9, 1.0 ,INTERP_LINEAR,INTERP_LINEAR,INTERP_LINEAR 
EnvHiHat      EnvelopeADSR     0.0005,0.131,0.015,0.0, 1.0 ,INTERP_LINEAR,INTERP_LINEAR,INTERP_LINEAR


instruments:
INSTR_SINE = ($-instruments)/sizeof.Instrument
instrSine      Instrument      EnvRegular, 0, 0, 0, 0, 0

INSTR_NOISE = ($-instruments)/sizeof.Instrument
;instrNoise     Instrument      <0.5,0.5,0.5,0.5, 1.0 ,INTERP_LINEAR,INTERP_LINEAR,INTERP_LINEAR>, OSC_NOISE
instrNoise     Instrument      EnvRegular, 0, 0, 0, 0, 0
INSTR_SAW = ($-instruments)/sizeof.Instrument
;instrSaw       Instrument      <0.1,0.1,0.1,0.5, 1.0 ,INTERP_LINEAR,INTERP_LINEAR,INTERP_LINEAR>, OSC_SAW
instrSaw       Instrument      EnvRegular, 0, 0, 0, 0, 0
INSTR_TRIANGLE = ($-instruments)/sizeof.Instrument
;instrTriangle  Instrument      <0.5,0.5,0.5,0.5, 1.0 ,INTERP_LINEAR,INTERP_LINEAR,INTERP_LINEAR>, OSC_TRIANGLE
instrTriangle  Instrument      EnvRegular, 0, 0, 0, 0, 0
INSTR_HIHAT = ($-instruments)/sizeof.Instrument
;instrHiHat     Instrument      <0.0001,0.181,0.1,0.0, 0.3 ,INTERP_LINEAR,INTERP_LINEAR,INTERP_LINEAR>, OSC_NOISE
instrHihat     Instrument      EnvHiHat, 0, 0, 0, 0, 0

instrumentsEnd:



UNISON_NONE = 0
UNISON_PRESENT = 1

OSC_SINE = 0
OSC_SQUARE = 1
OSC_SAW = 2
OSC_TRIANGLE = 3
OSC_NOISE = 4

oscSine       Oscillator    OSC_SINE, 0, 0.0
oscSquare     Oscillator    OSC_SQUARE, 0, 0.0
oscSaw        Oscillator    OSC_SAW, 0, 0.0
oscTriangle   Oscillator    OSC_TRIANGLE, 0, 0.0
oscNoise      Oscillator    OSC_NOISE, 0, 0.0