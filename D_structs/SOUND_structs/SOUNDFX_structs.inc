struct DoublyLinkedList
       next              dd     ?
       prev              dd     ?
       data              dd     ?
ends

struct SortedStack  
       next              dd     ?
       data              dd     ?
ends

struct EnvelopeADSR
       attackTime        dd     ?
       decayTime         dd     ?
       releaseTime       dd     ?

       sustainAmpl       dd     ?
       startAmpl         dd     ?  

       interpAttack      db     ?
       interpDecay       db     ?
       interpRelease     db     ?
ends

INTERP_REVERSE          = 10000000b

INTERP_LINEAR           = 0
INTERP_SQUARE           = 1
INTERP_CUBIC            = 2
INTERP_QUADRA           = 3
INTERP_TRIANGLE         = 4
INTERP_SINE             = 5


struct Instrument
       envelope          dd     ? 
       masterValue       dd     ?
       oscListPtr        dd     ?       
       msgPollPtr        dd     ?        
       filter            dd     ?
       reverb            dd     ?     
ends


struct Oscillator
       oscType           db     ?
       voices            db     ?
       detune            dd     ?
       pitchLFO          dd     ?
ends

EnvBasic      EnvelopeADSR     0.0005, 1.0, 0.0015, 1.0, 1.0, INTERP_LINEAR, INTERP_LINEAR, INTERP_LINEAR
EnvRegular    EnvelopeADSR     0.5,0.5,0.5,0.9, 1.0 ,INTERP_LINEAR,INTERP_LINEAR,INTERP_LINEAR 
EnvHiHat      EnvelopeADSR     0.0005,0.131,0.015,0.0, 1.0 ,INTERP_LINEAR,INTERP_LINEAR,INTERP_LINEAR
EnvSynth      EnvelopeADSR     0.042, 1.0, 0.64, 1.0, 1.0, INTERP_LINEAR, INTERP_LINEAR, INTERP_SQUARE
EnvPads       EnvelopeADSR     0.094, 0.116, 0.931, 1.0, 1.0, INTERP_SQUARE, INTERP_SQUARE
EnvTom        EnvelopeADSR     0.0005, 0.304, 0.01, 0.0, 1.0, INTERP_LINEAR, INTERP_SQUARE, INTERP_LINEAR
; EnvTom        EnvelopeADSR     0.0005, 0.304, 0.01, 1.0, 1.0, INTERP_LINEAR, INTERP_SQUARE, INTERP_LINEAR

; lacking hold value. :( that's why:
KICK_TIME     equ    0.108
EnvKick       EnvelopeADSR     0.0005, KICK_TIME, 0.150, 1.0, 1.0, INTERP_LINEAR, INTERP_LINEAR, INTERP_LINEAR
; man, I wish I'd implemented envelopes for oscillators
EnvSnareTail  EnvelopeADSR     0.0005, 0.667, 0.0015, 0.0, 1.0, INTERP_LINEAR, INTERP_QUADRA, INTERP_LINEAR
EnvSnareBody  EnvelopeADSR     0.0005, 0.287, 0.0015, 0.0, 1.0, INTERP_LINEAR, INTERP_CUBIC, INTERP_LINEAR

instruments:
; INSTR_SINE = ($-instruments)/sizeof.Instrument
; instrSine      Instrument      EnvRegular, 0, 0, 0

; INSTR_NOISE = ($-instruments)/sizeof.Instrument
; ;instrNoise     Instrument      <0.5,0.5,0.5,0.5, 1.0 ,INTERP_LINEAR,INTERP_LINEAR,INTERP_LINEAR>, OSC_NOISE
; instrNoise     Instrument      EnvRegular, 0, 0, 0
; INSTR_SAW = ($-instruments)/sizeof.Instrument
; ;instrSaw       Instrument      <0.1,0.1,0.1,0.5, 1.0 ,INTERP_LINEAR,INTERP_LINEAR,INTERP_LINEAR>, OSC_SAW
; instrSaw       Instrument      EnvRegular, 0, 0, 0
; INSTR_TRIANGLE = ($-instruments)/sizeof.Instrument
; ;instrTriangle  Instrument      <0.5,0.5,0.5,0.5, 1.0 ,INTERP_LINEAR,INTERP_LINEAR,INTERP_LINEAR>, OSC_TRIANGLE
; instrTriangle  Instrument      EnvRegular, 0, 0, 0
; ;instrHiHat     Instrument      <0.0001,0.181,0.1,0.0, 0.3 ,INTERP_LINEAR,INTERP_LINEAR,INTERP_LINEAR>, OSC_NOISE
INSTR_HIHAT = ($-instruments)/sizeof.Instrument
instrHihat     Instrument      EnvHiHat, 0.25, 0, 0, 0, 0
INSTR_SYNTH = ($-instruments)/sizeof.Instrument 
instrSynth     Instrument      EnvSynth, 0.8, 0, 0, 0, 0
INSTR_BASS = ($-instruments)/sizeof.Instrument 
instrBass      Instrument      EnvBasic, 1.0, 0, 0, 0, 0
INSTR_PADS = ($-instruments)/sizeof.Instrument
instrPads      Instrument      EnvPads, 1.0, 0, 0, 0, 0
INSTR_TOM  = ($-instruments)/sizeof.Instrument
instrTom       Instrument      EnvTom, 0.8, 0, 0, 0, 0
INSTR_KICK = ($-instruments)/sizeof.Instrument
instrKick      Instrument      EnvKick, 1.0, 0, 0, 0, 0
INSTR_SNARETAIL = ($-instruments)/sizeof.Instrument 
instrSnareTail Instrument      EnvSnareTail, 0.75, 0, 0, 0, 0
INSTR_SNAREBODY = ($-instruments)/sizeof.Instrument
instrSnareBody Instrument      EnvSnareBody, 1.5, 0, 0, 0, 0
instrumentsEnd:
instrumentsCount = ($ - instruments)/sizeof.Instrument



UNISON_NONE = 0
UNISON_PRESENT = 1

OSC_SINE = 0
OSC_SQUARE = 1
OSC_SAW = 2
OSC_TRIANGLE = 3
OSC_NOISE = 4

oscSine       Oscillator    OSC_SINE, 0, 0.0, 0
oscTomSine    Oscillator    OSC_SINE, 0, 0.0, LFOTomCoarse
oscKickSine   Oscillator    OSC_SINE, 0, 0.0, LFOKickCoarse
oscSnareSine  Oscillator    OSC_SINE, 0, 0.0, LFOSnareCoarse
oscSquare     Oscillator    OSC_SQUARE, 0, 0.0, 0
oscSaw        Oscillator    OSC_SAW, 0, 0.0, 0
oscSawPads    Oscillator    OSC_SAW, 4, 0.6, 0
oscSynthSaw   Oscillator    OSC_SAW, 0, 0.0, LFOSynthFine
oscTriangle   Oscillator    OSC_TRIANGLE, 0, 0.0, 0
oscNoise      Oscillator    OSC_NOISE, 0, 0.0, 0
oscSnareNoise Oscillator    OSC_NOISE, 0, 0.0, 0