struct Oscillator
       oscType           db     ?
       voices            db     ?
       detune            dd     ?
ends

struct LFONew
       target            db     ?         ; what it modifies
       rhythm            dd     ?
       startValue        dd     ?
       deltaValue        dd     ?
       mode              db     ?         ; loop, envelope 
       interpType        dw     ?        
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

struct InstrFilter
       coeffs            ButterworthCoeffs
       leftSamples       SampleArray
       rightSamples      SampleArray
ends