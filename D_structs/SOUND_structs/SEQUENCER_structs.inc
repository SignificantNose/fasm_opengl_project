struct SeqMessage
       msgData           dd        ?
       pattern           dd        ?
ends

struct Sequencer
       seqMsgArray       dd        ?
       seqMsgCount       dd        ?      
       tempo             dd        ?
       startTime         dd        ?

       bars              db        ?
       steps             db        ?
ends

