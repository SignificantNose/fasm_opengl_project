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

LFOMODE_LOOP  = 0
LFOMODE_ENV   = 1
LFOCutoff     LFO    6.0, 40.0, 600.0, LFOMODE_LOOP, INTERP_REVERSELINEAR
LFOFinePitch  LFO    3.0, 0.0, 3.0, LFOMODE_LOOP, INTERP_TRIANGLE