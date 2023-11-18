struct Oscillator
       oscType           db     ?
       voices            db     ?
       detune            dd     ?
       pitchLFO          dd     ?
ends

struct LFO
       rhythm            dd     ?
       startValue        dd     ?
       deltaValue        dd     ?
       mode              db     ?         ; loop, envelope 
       interpType        db     ?        
       ; cutoff frequency must be modified once, right before synthesis
       ; pitch:
       ;        if envelope - each has its own
       ;        if not - general for everyone
       ;        but in general the lfo for pitch can be calculated using 
       ;        the trigger time
       ; for mode, e.g. pitch modulation:
       ;      if the mode is envelope, count from trigger time
       ;      else - from global time 
ends

struct ButterworthCoeffs
       b0                dd     ?
       b1                dd     ?
       b2                dd     ?
       a1                dd     ? 
       a2                dd     ?
ends

; yikes
struct SampleArray
       x0                dd     ?
       x1                dd     ?
       x2                dd     ?  
       
       y0                dd     ?
       y1                dd     ?
       y2                dd     ?
ends
COUNTSHIFT = 2

struct InstrFilter
       coeffs            ButterworthCoeffs
       leftSamples       SampleArray
       rightSamples      SampleArray
       cutoffFreqLFO     dd    ?
ends

LFOMODE_LOOP  = 0
LFOMODE_ENV   = 1
LFOCutoff     LFO    6.0, 40.0, 600.0, LFOMODE_LOOP, INTERP_REVERSELINEAR
LFOFinePitch  LFO    1.0, 1.0, 0.1, LFOMODE_LOOP, INTERP_REVERSELINEAR

;struct Reverb
       
;ends