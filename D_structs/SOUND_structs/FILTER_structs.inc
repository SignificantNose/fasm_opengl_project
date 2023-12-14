FILTER_NONE          = 0
FILTER_LOPASS        = 1
FILTER_HIPASS        = 2
FILTER_BANDPASS      = 3

FILTERCOEF_CONST     = 0
FILTERCOEF_DYNAMIC   = 1

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