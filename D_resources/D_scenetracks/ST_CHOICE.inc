ST_Choice.Msgs:
       UnprocessedMessage          <E3, 0.6666666, 0.0>, INSTR_BASS
       UnprocessedMessage          <G3, 0.3333333, 0.6666666>, INSTR_BASS
       UnprocessedMessage          <E3, 0.3333333, 1.0>, INSTR_BASS

       UnprocessedMessage          <E3, 0.05, 0.0>, INSTR_KEY
       UnprocessedMessage          <E3, 0.05, 0.3333333>, INSTR_KEY
       UnprocessedMessage          <G3, 0.05, 0.6666666>, INSTR_KEY
       UnprocessedMessage          <E3, 0.05, 1.0>, INSTR_KEY
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