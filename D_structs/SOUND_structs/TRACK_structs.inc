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

; struct that keeps a pointer to the
; instrument played and its index to
; play the instruments more optimally
; (used as a type of elements in 
; TrackInstrumentList field that points
; to an array of this structs) 
struct InstrDefiner
        pInstrument     dd      ?
        instrNum        db      ?
ends 

; struct for a more optimal approach to 
; playing the instruments: it allows to 
; store only the necessary instruments 
; that are actually played in the current
; track
struct TrackInstrumentList 
        InstrDefinerArray       dd      ?
        InstrCount              dd      ?
ends 