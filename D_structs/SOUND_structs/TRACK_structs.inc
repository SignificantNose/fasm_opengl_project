; PackedTrack is a struct that keeps all the
; necessary data to produce a sound buffer
; containing actual great-sounding sound
; of your dreams
struct PackedTrack
       trackDuration     dd      ?
       pMsgStack         dd      ?

       pMsgsStart        dd      ?
       MsgsCount         dd      ?
       pSequencers       dd      ?
       SequencersCount   dd      ?
ends

; Track is a struct that contains a generated
; sound buffer and the duration of the generated
; sound data (basically saying, Track is
; processed PackedTrack)
struct Track 
        trackDuration   dd      ?
        buffer          dd      ?
ends 