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


FSh4          equ      369.99
D4            equ      293.66     
B3            equ      246.94

G4            equ      392.00	
DSh4          equ      311.13	
C4            equ      261.63

A4            equ      440.00
F4            equ      349.23
D4            equ      293.66

A6            equ      1760.00
FSh6          equ      1479.98
D6            equ      1174.66
B5            equ      987.77
C6            equ      1046.50
G6            equ      1567.98
F6            equ      1396.91

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

msg13           UnprocessedMessage        <FSh4,1.5,6.0>, INSTR_SYNTH

msg14           UnprocessedMessage        <D4,1.5,6.0>, INSTR_SYNTH
msg15           UnprocessedMessage        <B3,1.5,6.0>, INSTR_SYNTH

msg16           UnprocessedMessage        <G4,0.9140625,7.5390625>, INSTR_SYNTH
msg17           UnprocessedMessage        <DSh4,0.9140625,7.5390625>, INSTR_SYNTH
msg18           UnprocessedMessage        <C4,0.9140625,7.5390625>, INSTR_SYNTH

msg19           UnprocessedMessage        <G4,0.2421875,8.7109375>, INSTR_SYNTH
msg20           UnprocessedMessage        <DSh4,0.2421875,8.7109375>, INSTR_SYNTH
msg21           UnprocessedMessage        <C4,0.2421875,8.7109375>, INSTR_SYNTH

msg22           UnprocessedMessage        <A4,2.5546875,9.0078125>, INSTR_SYNTH
msg23           UnprocessedMessage        <F4,2.5546875,9.0078125>, INSTR_SYNTH
msg24           UnprocessedMessage        <D4,2.5546875,9.0078125>, INSTR_SYNTH


msg25            UnprocessedMessage        <FSh3, 1.5, 12.0>, INSTR_SYNTH
msg26            UnprocessedMessage        <D3, 1.5, 12.0>, INSTR_SYNTH
msg27            UnprocessedMessage        <B2, 1.5, 12.0>, INSTR_SYNTH
msg28            UnprocessedMessage        <FSh4, 1.5, 12.0>, INSTR_SYNTH
msg29            UnprocessedMessage        <D4, 1.5, 12.0>, INSTR_SYNTH
msg30            UnprocessedMessage        <B3, 1.5, 12.0>, INSTR_SYNTH

msg31            UnprocessedMessage        <G3,0.9140625,13.5390625>, INSTR_SYNTH
msg32            UnprocessedMessage        <DSh3,0.9140625,13.5390625>, INSTR_SYNTH
msg33            UnprocessedMessage        <C3,0.9140625,13.5390625>, INSTR_SYNTH
msg34            UnprocessedMessage        <G4,0.9140625,13.5390625>, INSTR_SYNTH
msg35            UnprocessedMessage        <DSh4,0.9140625,13.5390625>, INSTR_SYNTH
msg36            UnprocessedMessage        <C4,0.9140625,13.5390625>, INSTR_SYNTH

msg37            UnprocessedMessage        <G3,0.2421875,14.7109375>, INSTR_SYNTH
msg38            UnprocessedMessage        <DSh3,0.2421875,14.7109375>, INSTR_SYNTH
msg39            UnprocessedMessage        <C3,0.2421875,14.7109375>, INSTR_SYNTH
msg40            UnprocessedMessage        <G4,0.2421875,14.7109375>, INSTR_SYNTH
msg41            UnprocessedMessage        <DSh4,0.2421875,14.7109375>, INSTR_SYNTH
msg42            UnprocessedMessage        <C4,0.2421875,14.7109375>, INSTR_SYNTH

msg43           UnprocessedMessage        <A3,2.5546875,15.0078125>, INSTR_SYNTH
msg44           UnprocessedMessage        <F3,2.5546875,15.0078125>, INSTR_SYNTH
msg45           UnprocessedMessage        <D3,2.5546875,15.0078125>, INSTR_SYNTH
msg46           UnprocessedMessage        <A4,2.5546875,15.0078125>, INSTR_SYNTH
msg47           UnprocessedMessage        <F4,2.5546875,15.0078125>, INSTR_SYNTH
msg48           UnprocessedMessage        <D4,2.5546875,15.0078125>, INSTR_SYNTH





secmsg24            UnprocessedMessage        <FSh3, 1.5, 18.0>, INSTR_SYNTH
secmsg26            UnprocessedMessage        <D3, 1.5, 18.0>, INSTR_SYNTH
secmsg27            UnprocessedMessage        <B2, 1.5, 18.0>, INSTR_SYNTH
secmsg28            UnprocessedMessage        <FSh4, 1.5, 18.0>, INSTR_SYNTH
secmsg29            UnprocessedMessage        <D4, 1.5, 18.0>, INSTR_SYNTH
secmsg30            UnprocessedMessage        <B3, 1.5, 18.0>, INSTR_SYNTH
addmsg1             UnprocessedMessage        <A6, 0.3828125, 18.0234375>, INSTR_SYNTH
addmsg2             UnprocessedMessage        <FSh6, 0.375, 18.40625>, INSTR_SYNTH
addmsg3             UnprocessedMessage        <D6, 0.3671875, 18.7890625>, INSTR_SYNTH
addmsg4             UnprocessedMessage        <B5, 0.375, 19.1484375>, INSTR_SYNTH


secmsg31            UnprocessedMessage        <G3,0.9140625,19.5390625>, INSTR_SYNTH
secmsg32            UnprocessedMessage        <DSh3,0.9140625,19.5390625>, INSTR_SYNTH
secmsg33            UnprocessedMessage        <C3,0.9140625,19.5390625>, INSTR_SYNTH
secmsg34            UnprocessedMessage        <G4,0.9140625,19.5390625>, INSTR_SYNTH
secmsg35            UnprocessedMessage        <DSh4,0.9140625,19.5390625>, INSTR_SYNTH
secmsg36            UnprocessedMessage        <C4,0.9140625,19.5390625>, INSTR_SYNTH

addmsg5             UnprocessedMessage        <A6, 0.3828125, 19.5234375>, INSTR_SYNTH
addmsg6             UnprocessedMessage        <FSh6, 0.375, 19.90625>, INSTR_SYNTH
addmsg7             UnprocessedMessage        <D6, 0.3671875, 20.2890625>, INSTR_SYNTH
addmsg8             UnprocessedMessage        <C6, 0.375, 20.6484375>, INSTR_SYNTH

secmsg37            UnprocessedMessage        <G3,0.2421875,20.7109375>, INSTR_SYNTH
secmsg38            UnprocessedMessage        <DSh3,0.2421875,20.7109375>, INSTR_SYNTH
secmsg39            UnprocessedMessage        <C3,0.2421875,20.7109375>, INSTR_SYNTH
secmsg40            UnprocessedMessage        <G4,0.2421875,20.7109375>, INSTR_SYNTH
secmsg41            UnprocessedMessage        <DSh4,0.2421875,20.7109375>, INSTR_SYNTH
secmsg42            UnprocessedMessage        <C4,0.2421875,20.7109375>, INSTR_SYNTH

secmsg43           UnprocessedMessage        <A3,2.5546875,21.0078125>, INSTR_SYNTH
secmsg44           UnprocessedMessage        <F3,2.5546875,21.0078125>, INSTR_SYNTH
secmsg45           UnprocessedMessage        <D3,2.5546875,21.0078125>, INSTR_SYNTH
secmsg46           UnprocessedMessage        <A4,2.5546875,21.0078125>, INSTR_SYNTH
secmsg47           UnprocessedMessage        <F4,2.5546875,21.0078125>, INSTR_SYNTH
secmsg48           UnprocessedMessage        <D4,2.5546875,21.0078125>, INSTR_SYNTH

addmsg9             UnprocessedMessage        <F6, 0.484375, 21.0546875>, INSTR_SYNTH
addmsg10             UnprocessedMessage        <A6, 0.2265625, 21.5234375>, INSTR_SYNTH
addmsg11             UnprocessedMessage        <G6, 0.2265625, 21.671875>, INSTR_SYNTH
addmsg12             UnprocessedMessage        <D6, 0.46875, 21.8671875>, INSTR_SYNTH





TRACK1_MESSAGESCOUNT = ($-track1msgs)/sizeof.UnprocessedMessage

;messagesPtr     dd      messages

track1          Track                     24.0, track1msgs, TRACK1_MESSAGESCOUNT