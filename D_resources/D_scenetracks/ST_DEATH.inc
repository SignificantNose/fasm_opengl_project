ST_Death.Msgs:
       UnprocessedMessage          <C1, 2.66, 0.0>, INSTR_LASER
       UnprocessedMessage          <G0, 2.66, 0.2>, INSTR_LASER
       UnprocessedMessage          <C0, 2.66, 0.4>, INSTR_LASER

ST_Death.MsgsCount = ($-ST_Death.Msgs)/sizeof.UnprocessedMessage


; sequencers array
ST_Death.Seqs:
       ; Sequencer                 testTrack_SeqMsgs, testTrack_SeqMsgsCount, 90.0, 0.0, 4, 4 
ST_Death.SeqsCount = ($-ST_Death.Seqs)/sizeof.Sequencer


; sequencer messages
ST_Death.SeqMsgs:
       ; SeqMessage                testtrack2seqmessagehihat, 0111111111111111b
;       SeqMessage                testtrack2seqmessagehihat2, 8AAAh                
ST_Death.SeqMsgsCount = ($-ST_Death.SeqMsgs)/sizeof.SeqMessage

; testtrack2seqmessagehihat   UnprocessedMessage   <A1, 0.131614, ?>, INSTR_HIHAT
; testtrack2seqmessagehihat2  UnprocessedMessage   <A1, 0.131614, ?>, INSTR_HIHAT

; track2          PackedTrack                     10.64, 0