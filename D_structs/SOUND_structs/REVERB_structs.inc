struct ReverbBuffer
    dataLeft            dd      ?
    dataRight           dd      ?
    delayInSamples      dd      ?
    gain                dd      ?
    index               dd      ?
ends

struct Reverberator
    arrOfBuffers        dd      ?
    countBuffers        dd      ?           ; if the amount of buffers is different, it will be easier to implement
ends 


Reverb.DelayMultipliers:
    dd      1.0
    dd      0.8634303555
    dd      0.6030772429
    dd      0.4372888297
    dd      0.2777382284
REVERB_COUNTBUFFERS = ($-Reverb.DelayMultipliers)/4
    

; max gain = 0.262, that's why:
Reverb.GainMultipliers:
    dd      0.139122
    dd      0.17071658
    dd      0.19752442
    dd      0.227182558
    dd      0.262