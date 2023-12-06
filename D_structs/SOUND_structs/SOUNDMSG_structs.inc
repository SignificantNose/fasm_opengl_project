; MessageData struct is a struct containing
; all the general data that is needed for 
; the message to be played (without any
; additional effects applied to the message)
struct MessageData
       msgFreq           dd     ?
       msgDuration       dd     ?
       msgTrigger        dd     ?
ends

; UnprocessedMessage is a struct that is 
; user-friendly in terms of determination
; of the general data of the message and its
; belonging to a specific instrument
struct UnprocessedMessage
       msgData           MessageData
       instrNumber       db     ?
ends

; InstrumentMessage is a struct that allows for
; applying effects (mainly frequency modulation)
; to the sound message. used to be stored in 
; instrument list
struct InstrumentMessage
       msgData           MessageData

       ; I have to calculate LFO frequency based on the previous
       ; value provided with LFO. Do not like this approach. 
       LFOPrevValue      dd     ?
ends


msgListHead     dd      LIST_NONE
; Message poll
messages:

;msg1            UnprocessedMessage      <165.0, 6.0, 0.0>, INSTR_SINE
;msg2            UnprocessedMessage      <450.0,3.0,0.0>, INSTR_SINE
msg3            UnprocessedMessage      <165.0,2.0,0.0>, INSTR_SAW

msgEnd:

messagesPtr     dd      messages