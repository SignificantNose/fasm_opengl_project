ST_Crash.Msgs:
        UnprocessedMessage          <A5, 2.66, 0.0>, INSTR_BASS
    ;    UnprocessedMessage        <E3,2.66,0.0>, INSTR_BASS
    ;    UnprocessedMessage        <G3,2.66,2.66>, INSTR_BASS
    ;    UnprocessedMessage        <B3,2.66,5.32>, INSTR_BASS
    ;    UnprocessedMessage        <A3,2.66,7.98>, INSTR_BASS
ST_Crash.MsgsCount = ($-ST_Crash.Msgs)/sizeof.UnprocessedMessage


; sequencers array
ST_Crash.Seqs:
       ; Sequencer                 testTrack_SeqMsgs, testTrack_SeqMsgsCount, 90.0, 0.0, 4, 4 
ST_Crash.SeqsCount = ($-ST_Crash.Seqs)/sizeof.Sequencer


; sequencer messages
ST_Crash.SeqMsgs:
       ; SeqMessage                testtrack2seqmessagehihat, 0111111111111111b
;       SeqMessage                testtrack2seqmessagehihat2, 8AAAh                
ST_Crash.SeqMsgsCount = ($-ST_Crash.SeqMsgs)/sizeof.SeqMessage

; testtrack2seqmessagehihat   UnprocessedMessage   <A1, 0.131614, ?>, INSTR_HIHAT
; testtrack2seqmessagehihat2  UnprocessedMessage   <A1, 0.131614, ?>, INSTR_HIHAT

; track2          PackedTrack                     10.64, 0