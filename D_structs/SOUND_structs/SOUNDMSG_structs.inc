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



FSh3          equ      181.63
D3            equ      144.16     
B2            equ      121.23

G3            equ      192.43
DSh3          equ      152.74
C3            equ      128.43

A3            equ      216.00
F3            equ      171.44
D3            equ      144.16


;msgListHead     dd      LIST_NONE
;msg1            UnprocessedMessage      <165.0, 6.0, 0.0>, INSTR_SINE
;msg2            UnprocessedMessage      <450.0,3.0,0.0>, INSTR_SINE
;msg3            UnprocessedMessage      <165.0,2.0,0.0>, INSTR_SAW

; Message poll
track1msgs:

msg1            UnprocessedMessage        <FSh3, 1.5, 0.0>, INSTR_SYNTH
msg2            UnprocessedMessage        <D3, 1.5, 0.0>, INSTR_SYNTH
msg3            UnprocessedMessage        <B2, 1.5, 0.0>, INSTR_SYNTH

msg4            UnprocessedMessage        <G3,0.9140625,1.5390625>, INSTR_SYNTH
msg5            UnprocessedMessage        <DSh3,0.9140625,1.5390625>, INSTR_SYNTH
msg6            UnprocessedMessage        <C3,0.9140625,1.5390625>, INSTR_SYNTH

msg7            UnprocessedMessage        <G3,0.2421875,2.7109375>, INSTR_SYNTH
msg8            UnprocessedMessage        <DSh3,0.2421875,2.7109375>, INSTR_SYNTH
msg9            UnprocessedMessage        <C3,0.2421875,2.7109375>, INSTR_SYNTH

msg10           UnprocessedMessage        <A3,2.5546875,3.0078125>, INSTR_SYNTH
msg11           UnprocessedMessage        <F3,2.5546875,3.0078125>, INSTR_SYNTH
msg12           UnprocessedMessage        <D3,2.5546875,3.0078125>, INSTR_SYNTH
TRACK1_MESSAGESCOUNT = ($-track1msgs)/sizeof.UnprocessedMessage

;messagesPtr     dd      messages

track1          Track                     24.0, track1msgs, TRACK1_MESSAGESCOUNT