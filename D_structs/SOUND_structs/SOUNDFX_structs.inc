struct Oscillator
       oscType           db     ?
       voices            db     ?
       detune            dd     ?
       pitchLFO          dd     ?
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


;struct Reverb
       
;ends