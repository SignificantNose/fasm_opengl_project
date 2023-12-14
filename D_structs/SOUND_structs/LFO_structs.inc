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

       ; upd: the problem with LFO is that I was very naive about 
       ; frequency modulation. that's why the expected way of LFO
       ; modulation was not fully implemented as intended: it needed
       ; to be unique in case of frequency modulation: there the value 
       ; that is acquired from LFOGetValue is decreased by the amount of 
       ; start value - only the delta value (amplitude) was required to
       ; modulate the frequency. that is a tragedy.
ends

LFOMODE_LOOP     = 00000000b
LFOMODE_ENV      = 00000001b
LFOMODE_UNIPOLAR = 00000000b
LFOMODE_BIPOLAR  = 00000010b

;LFOCutoff     LFO    6.0, 40.0, 600.0, LFOMODE_LOOP, INTERP_REVERSELINEAR
LFOCutoff     LFO    6.0, 400.0, 1000.0, LFOMODE_LOOP or LFOMODE_UNIPOLAR, INTERP_LINEAR or INTERP_REVERSE
LFOSynthFine  LFO    0.75, 0.0, 0.0017, LFOMODE_LOOP or LFOMODE_BIPOLAR, INTERP_TRIANGLE
LFOTomCoarse  LFO    3.0, 0.0, 20.0, LFOMODE_ENV or LFOMODE_UNIPOLAR, INTERP_LINEAR or INTERP_REVERSE
LFOKickCoarse LFO    3.4, 0.0, 20.0, LFOMODE_ENV or LFOMODE_UNIPOLAR, INTERP_QUADRA or INTERP_REVERSE
LFOSnareCoarse LFO   1.5, 0.0, 10.0, LFOMODE_ENV or LFOMODE_BIPOLAR, INTERP_CUBIC or INTERP_REVERSE