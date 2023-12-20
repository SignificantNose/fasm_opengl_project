ST_PreRun.Msgs:
       UnprocessedMessage          <C3, 1.0, 0.0>, INSTR_BASS
       UnprocessedMessage          <D3, 1.0, 1.0>, INSTR_BASS

       UnprocessedMessage          <E2, 0.333333333, 1.66666666>, INSTR_TOM 
       UnprocessedMessage          <E2, 0.333333333, 1.83333333>, INSTR_TOM 
ST_PreRun.MsgsCount = ($-ST_PreRun.Msgs)/sizeof.UnprocessedMessage


; sequencers array
ST_PreRun.Seqs:
       ; Sequencer                 testTrack_SeqMsgs, testTrack_SeqMsgsCount, 90.0, 0.0, 4, 4 
ST_PreRun.SeqsCount = ($-ST_PreRun.Seqs)/sizeof.Sequencer


; sequencer messages
ST_PreRun.SeqMsgs:
       ; SeqMessage                testtrack2seqmessagehihat, 0111111111111111b
;       SeqMessage                testtrack2seqmessagehihat2, 8AAAh                
ST_PreRun.SeqMsgsCount = ($-ST_PreRun.SeqMsgs)/sizeof.SeqMessage

; testtrack2seqmessagehihat   UnprocessedMessage   <A1, 0.131614, ?>, INSTR_HIHAT
; testtrack2seqmessagehihat2  UnprocessedMessage   <A1, 0.131614, ?>, INSTR_HIHAT

; track2          PackedTrack                     10.64, 0