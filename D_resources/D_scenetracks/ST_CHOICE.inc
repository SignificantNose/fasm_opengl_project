ST_Choice.Msgs:
       UnprocessedMessage        <E3,2.66,0.0>, INSTR_BASS
       UnprocessedMessage        <G3,2.66,2.66>, INSTR_BASS
       UnprocessedMessage        <B3,2.66,5.32>, INSTR_BASS
       UnprocessedMessage        <A3,2.66,7.98>, INSTR_BASS

ST_Choice.MsgsCount = ($-ST_Choice.Msgs)/sizeof.UnprocessedMessage


; sequencers array
ST_Choice.Seqs:
       ; Sequencer                 testTrack_SeqMsgs, testTrack_SeqMsgsCount, 90.0, 0.0, 4, 4 
ST_Choice.SeqsCount = ($-ST_Choice.Seqs)/sizeof.Sequencer


; sequencer messages
ST_Choice.SeqMsgs:
       ; SeqMessage                testtrack2seqmessagehihat, 0111111111111111b
;       SeqMessage                testtrack2seqmessagehihat2, 8AAAh                
ST_Choice.SeqMsgsCount = ($-ST_Choice.SeqMsgs)/sizeof.SeqMessage

; testtrack2seqmessagehihat   UnprocessedMessage   <A1, 0.131614, ?>, INSTR_HIHAT
; testtrack2seqmessagehihat2  UnprocessedMessage   <A1, 0.131614, ?>, INSTR_HIHAT

; track2          PackedTrack                     10.64, 0