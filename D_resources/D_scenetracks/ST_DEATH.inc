ST_Death.Msgs:
       UnprocessedMessage          <E3, 0.6666666, 0.0>, INSTR_BASS
       UnprocessedMessage          <G3, 0.3333333, 0.6666666>, INSTR_BASS
       UnprocessedMessage          <E3, 0.3333333, 1.0>, INSTR_BASS

       UnprocessedMessage          <E3, 0.05, 0.0>, INSTR_KEY
       UnprocessedMessage          <E3, 0.05, 0.3333333>, INSTR_KEY
       UnprocessedMessage          <G3, 0.05, 0.6666666>, INSTR_KEY
       UnprocessedMessage          <E3, 0.05, 1.0>, INSTR_KEY
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